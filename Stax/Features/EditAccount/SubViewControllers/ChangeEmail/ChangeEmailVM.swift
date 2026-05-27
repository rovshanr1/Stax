//
//  ChangeEmailVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 20.05.26.
//

import Foundation
import Combine

final class ChangeEmailVM {
    
    struct Input {
        let emailChanged: PassthroughSubject<String, Never>
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
    
    //MARK: - Private User
    
    // Preivate State
    private var draftEmail: String
    
    // Original User
    private let originalUser: UserModel
    
    // Services
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    // Initial Items
    
    var initialEmail: String{
        return originalUser.email
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(authService: AuthServiceProtocol = AuthService(),
         userService: UserServiceProtocol = UserService(),
         userModel: UserModel
    ) {
        
        self.draftEmail = userModel.email
        
        self.authService = authService
        self.userService = userService
        self.originalUser = userModel
        
        self.input = .init(
            emailChanged: .init(),
            updateButtonTapped: .init(),
        )
        
        self.output = .init(
            isUpdateButtonEnabled: .init(false),
            isLoading: .init(false),
            errorMessage: .init(),
            saveCompletion: .init()
            
        )
        
        transform()
    }
    
    private func transform() {
        
        input.emailChanged
            .sink { [weak self] newEmail in
                guard let self else { return }
                
                self.draftEmail = newEmail
                self.checkIfUpdateShouldBeEnabled()
            }
            .store(in: &cancellables)
        
        input.updateButtonTapped
            .sink { [weak self] in
                self?.performSave()
            }
            .store(in: &cancellables)
        
    }
    
    
    //MARK: - Helper Methods
    private func checkIfUpdateShouldBeEnabled() {
        let cleanEmail = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //if we want to use it in the future
        let _ = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let _ = NSPredicate(format: "SELF MATCHES %@").evaluate(with: cleanEmail)
        
        let isValidFormat = cleanEmail.contains("@")
        
        let hasChanges = !cleanEmail.isEmpty && cleanEmail != originalUser.email && isValidFormat
        
        output.isUpdateButtonEnabled.send(hasChanges)
    }
    
    private func performSave() {
        output.isLoading.send(true)
        
        let cleanEmail = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        
        Task{
            do{
                try await authService.changeEmail(email: cleanEmail)
                
                try await userService.updateEmail(email: cleanEmail)
                
                await MainActor.run {
                    self.output.isLoading.send(false)
                    self.output.saveCompletion.send()
                }
            }catch{
                await MainActor.run{
                    self.output.isLoading.send(false)
                    self.output.errorMessage.send(error.localizedDescription)
                }
            }
        }
        
    }
}

