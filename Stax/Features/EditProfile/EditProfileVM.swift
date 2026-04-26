//
//  EditProfileVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.04.26.
//

import Foundation
import Combine

final class EditProfileVM{
    
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input {
        let profileItemSelected: PassthroughSubject<Data, Never>
        let nameChanged: PassthroughSubject<String, Never>
        let bioChanged: PassthroughSubject<String, Never>
        let saveButtonTapped: PassthroughSubject<Void, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output {
        let isSaveEnabled: CurrentValueSubject<Bool, Never>
        let currentProfileImage: CurrentValueSubject<Data?, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let saveCompleted: PassthroughSubject<Void, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //MARK: - Private Properties
    
    private let originalUser: UserModel
    
    //Draft State
    private var draftName: String
    private var draftBio: String
    private var draftImageData: Data?
    
    // Initial Items
    var initialImageURL: String?{
        return originalUser.profileImage
    }
    
    var initialName: String?{
        return originalUser.name
    }
    
    var initialBio: String?{
        return originalUser.bio
    }
    
    //Combine
    private var cancellables: Set<AnyCancellable> = []
    
    //Services
    private let userService: UserServiceProtocol
    private let imageService: ImageKitServiceProtocol
    private let userManager: UserManager
    
    
    init(
        userModel: UserModel,
        userService: UserServiceProtocol = UserService(),
        imageService: ImageKitServiceProtocol = ImageKitService(),
        userManager: UserManager
    ) {
        self.originalUser = userModel
        self.userService = userService
        self.imageService = imageService
        self.userManager = userManager
        
        self.draftName = userModel.name
        self.draftBio = userModel.bio ?? ""
        
        self.input = .init(
            profileItemSelected: .init(),
            nameChanged: .init(),
            bioChanged: .init(),
            saveButtonTapped: .init()
        )
        
        self.output = .init(
            isSaveEnabled: .init(false),
            currentProfileImage: .init(nil),
            isLoading: .init(false),
            errorMessage: .init(),
            saveCompleted: .init()
        )
        
        transform()
    }
    
    
    private func transform(){
        input.nameChanged
            .sink { [weak self] newName in
                self?.draftName = newName
                self?.checkIfSaveShouldBeEnabled( )
            }
            .store(in: &cancellables)
        
        input.bioChanged
            .sink { [weak self] newBio in
                self?.draftBio = newBio
                self?.checkIfSaveShouldBeEnabled()
            }
            .store(in: &cancellables)
        
        input.profileItemSelected
            .sink { [weak self] imageData in
                self?.draftImageData = imageData
                self?.output.currentProfileImage.send(imageData)
                self?.checkIfSaveShouldBeEnabled( )
            }
            .store(in: &cancellables)
        
        input.saveButtonTapped
            .sink { [weak self] in
                self?.performSave()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Validation Logic
    private func checkIfSaveShouldBeEnabled() {
        let cleanName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBio = draftBio.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let originalBio = originalUser.bio ?? ""
        
        let hasChanges = (cleanName != originalUser.name) ||
                                 (cleanBio != originalBio) ||
                                 (draftImageData != nil)
        
        let isValid = !cleanName.isEmpty
        
        output.isSaveEnabled.send(hasChanges && isValid)
    }
    
    //MARK: - Save Operation
    private func performSave(){
        output.isLoading.send(true)
        if let imageData = draftImageData{
            imageService.uploadProfileImage(image: imageData) { [weak self] result in
                guard let self else { return }
                
                switch result{
                case .success(let imageURL):
                    self.updateUserInDB(newURL: imageURL)
                case .failure(let error):
                    self.output.isLoading.send(false)
                    self.output.errorMessage.send(error.localizedDescription)
                }
            }
        }else{
            self.updateUserInDB(newURL: originalUser.profileImage)
        }
        
    }
    
    private func updateUserInDB(newURL: String?){
        userService.updateUserProfile(name: draftName, bio: draftBio, imageUrl: newURL) { [weak self] result in
            guard let self else { return }
            
            let finalName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalBio = draftBio.trimmingCharacters(in: .whitespacesAndNewlines)
            
            self.output.isLoading.send(false)
            
            switch result {
            case .success():
                var updateUser = self.originalUser
                updateUser.name = finalName
                updateUser.bio = finalBio
                updateUser.profileImage = newURL ?? self.originalUser.profileImage
                
                self.userManager.updateUser(user: updateUser)
                
                self.output.saveCompleted.send(())
            case .failure(let error):
                self.output.errorMessage.send(error.localizedDescription)
            }
        }
    }
}
