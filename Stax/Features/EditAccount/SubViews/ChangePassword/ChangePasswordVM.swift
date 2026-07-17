//
//  ChangePasswordVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.05.26.
//

import Foundation
import Combine

final class ChangePasswordVM {
    
    struct Input {
        let currentPassword: PassthroughSubject<String, Never>
        let passwordChanged: PassthroughSubject<String, Never>
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
    
    // Preivate State
    private var draftCurrentPassword: String = ""
    private var draftPassword: String = ""
    
    //Services
    private let authService: AuthServiceProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.authService = authService
        
        self.input = .init(currentPassword: .init(),
                           passwordChanged: .init(),
                           updateButtonTapped: .init())
        
        self.output = .init(isUpdateButtonEnabled: .init(false),
                            isLoading: .init(false),
                            errorMessage: .init(),
                            saveCompletion: .init())
        
        
        
        transform()
    }
    
    private func transform() {
        
        input.currentPassword
            .sink { [weak self] currentPassword in
                guard let self else { return }
                
                self.draftCurrentPassword = currentPassword
                
            }
            .store(in: &cancellables)
        
        input.passwordChanged
            .sink { [weak self] newPassword in
                guard let self else { return }
                
                self.draftPassword = newPassword
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
        let cleanPassword = draftPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCurrentPassword = draftCurrentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        let isValid = !cleanPassword.isEmpty && !cleanCurrentPassword.isEmpty && passwordPredicate.evaluate(with: cleanPassword)
        
        output.isUpdateButtonEnabled.send(isValid)
        
        
    }
    
    private func performSave(){
        output.isLoading.send(true)
        
        let cleanPassword = draftPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCurrentPassword = draftCurrentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task{
            do{
                try await authService.changePassword(currentPassword: cleanCurrentPassword,
                                                     newPassword: cleanPassword)
                
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

