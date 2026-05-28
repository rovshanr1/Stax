//
//  ChangeUserNameVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 27.05.26.
//

import Foundation
import Combine

final class ChangeUserNameVM {
    
    struct Input {
        let changeUserName: PassthroughSubject<String, Never>
        let updateButtonTapped: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        let isUpdateButtonEnabled: CurrentValueSubject<Bool, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let saveCompletion: PassthroughSubject<Void, Never>
    }
    
    let input: Input
    let output: Output
    
    //MARK: - Private Properties
    
    // draft User Name
    private var draftUserName: String
    
    
    // Services
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let userManager: UserManager
    
    // Initial Items
    
    var initialUserName: String {
        return userManager.currentUser?.name ?? ""
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(authService: AuthServiceProtocol = AuthService(),
         userService: UserServiceProtocol = UserService(),
         userManager: UserManager
    ) {
        
        self.draftUserName = userManager.currentUser?.name ?? ""
        
        self.authService = authService
        self.userService = userService
        self.userManager = userManager
        
        
        self.input = .init(
            changeUserName: .init(),
            updateButtonTapped: .init())
        
        self.output = .init(
            isUpdateButtonEnabled: .init(false),
            isLoading: .init(false),
            errorMessage: .init(),
            saveCompletion: .init()
        )
        
        transform()
    }
    
    private func transform() {
        input.changeUserName
            .sink { [weak self] newUserName in
                self?.draftUserName = newUserName
                self?.checkIsUpdateButtonEnabled()
            }
            .store(in: &cancellables)
        
        input.updateButtonTapped
            .sink { [weak self] in
                self?.saveUserName()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Validation Logic
    
    private func checkIsUpdateButtonEnabled() {
        let cleanUserName = draftUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let currentUserName = userManager.currentUser?.name else { return }
        
        let hasChanges = !cleanUserName.isEmpty && cleanUserName != currentUserName
        
        output.isUpdateButtonEnabled.send(hasChanges)
    }
    
    
    //MARK: - Save Operation
    
    private func saveUserName() {
        output.isLoading.send(true)
        
        let cleanUserName = draftUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task{
            do{
                try await authService.changeUserName(newName: cleanUserName)
                try await userService.updateUserName(name: cleanUserName)
                
                guard var upadetedUser = userManager.currentUser else { return }
                upadetedUser.name = cleanUserName
                
                userManager.updateUser(upadetedUser)
                
                await MainActor.run {
                    self.output.isLoading.send(false)
                    self.output.saveCompletion.send()
                }
            }catch{
                await MainActor.run {
                    self.output.isLoading.send(false)
                    self.output.errorMessage.send(error.localizedDescription)
                }
            }
        }
    }
}

