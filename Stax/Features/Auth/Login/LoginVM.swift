//
//  LoginVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import Foundation
import Combine

final class LoginVM{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input {
        let updateEmail: CurrentValueSubject<String, Never>
        let updatePassword: CurrentValueSubject<String, Never>
        let didTapLogin: PassthroughSubject<Void, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let isLoading: PassthroughSubject<Bool, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let success: PassthroughSubject<Bool, Never>
        let buttonIsEnabled: CurrentValueSubject<Bool, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Combine
    private var cancellables = Set<AnyCancellable>()
    
    
    let authService: AuthServiceProtocol
    
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        
        
        self.input = .init(updateEmail: .init(""),
                           updatePassword: .init(""),
                           didTapLogin: .init()
        )
        self.output = .init(isLoading: .init(),
                            errorMessage: .init(),
                            success: .init(),
                            buttonIsEnabled: .init(false),
        )
        
        transform()
    }
    
    
    private func transform(){
        Publishers.CombineLatest(
            input.updateEmail,
            input.updatePassword
        )
        .map { email, password in
            let isEmailValid = email.contains("@") && email.contains(".")
            let isPasswordValid = password.count >= 6
            
            return isEmailValid && isPasswordValid
        }
        .sink { [weak self] isValid in
            self?.output.buttonIsEnabled.send(isValid)
        }
        .store(in: &cancellables)
        
        input.didTapLogin
            .sink { [weak self] in
                guard let self else { return }
                
                self.output.isLoading.send(true)
                
                let email = self.input.updateEmail.value
                let password = self.input.updatePassword.value
                
                self.authService.login(email: email, password: password, profileImage: nil) { result in
                    self.output.isLoading.send(false)
                    
                    switch result{
                    case .success(let userModel):
                        KeychainHelper.shared.save(userModel.id)
                        self.output.success.send(true)
            
                    case .failure(let error):
                        
                        self.output.errorMessage.send(error.localizedDescription)
                    }
                }
                
            }
            .store(in: &cancellables)
    }

    
}
