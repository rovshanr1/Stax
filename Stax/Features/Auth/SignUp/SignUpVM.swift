//
//  SignUpVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import Foundation
import Combine

final class SignUpVM{
    
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input {
        let didTapSignUp: PassthroughSubject<Void, Never>
        let didTapSignIn: PassthroughSubject<Void, Never>
        let updateEmail: CurrentValueSubject<String, Never>
        let updateName: CurrentValueSubject<String, Never>
        let updatePassword: CurrentValueSubject<String, Never>
       
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
    
    //Services
    let authService: AuthServiceProtocol
    let userService: UserServiceProtocol
    
    init(authService: AuthServiceProtocol, userService: UserServiceProtocol) {
        self.authService = authService
        self.userService = userService
        
        self.input = .init(didTapSignUp: .init(),
                           didTapSignIn: .init(),
                           updateEmail: .init(""),
                           updateName: .init(""),
                           updatePassword: .init("")
        )
        self.output = .init(isLoading: .init(),
                            errorMessage: .init(),
                            success: .init(),
                            buttonIsEnabled: .init(false),
        )
        
        transform()
    }
    
    
    private func transform(){
        
        Publishers.CombineLatest3(
            input.updateName,
            input.updateEmail,
            input.updatePassword,
        )
        .map { name, email, password in
            let isNameValid = !name.isEmpty
            let isEmailValid = email.contains("@") && email.contains(".")
            let isPasswordValid = password.count >= 6
            return isNameValid && isEmailValid && isPasswordValid
        }
        .sink(receiveValue: { [weak self] isValid in
            self?.output.buttonIsEnabled.send(isValid)
        })
        .store(in: &cancellables)
        
        input.didTapSignUp
            .sink { [weak self] in
                guard let self else { return }
                
                self.output.isLoading.send(true)
                
                let name = self.input.updateName.value
                let email = self.input.updateEmail.value
                let password = self.input.updatePassword.value
                
                self.authService.register(name: name, email: email, password: password, profileImage: nil) { result in
                    self.output.isLoading.send(false)
                    
                    switch result {
                    case .success(let userModel):

                        self.userService.saveUser(user: userModel) { saveResult in
                            self.output.isLoading.send(false)
                            switch saveResult{
                            case .success:
                                KeychainHelper.shared.save(userModel.id)
                                self.output.success.send(true)
                            case .failure(let error):
                                self.output.errorMessage.send(error.localizedDescription)
                            }
                        }
                        
                    case .failure(let error):
                        
                        self.output.errorMessage.send(error.localizedDescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
  
}
