//
//  SettingsVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import Foundation
import Combine

final class SettingsVM {
    
    struct Input {
        let logoutTapped: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        let logoutCompleted: PassthroughSubject<Void, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
    }
    
    let input: Input
    let output: Output
    
    private var cancellables: Set<AnyCancellable> = []
    
    //Services
    private let userService: UserServiceProtocol
    private let userManager: UserManager
    
    init(userService: UserServiceProtocol = UserService(), userManager: UserManager) {
        self.userService = userService
        self.userManager = userManager
        
        self.input = .init(logoutTapped: .init())
        self.output = .init(logoutCompleted: .init(), errorMessage: .init(), isLoading: .init(false))
        
        transform()
    }
    
    private func transform() {
        input.logoutTapped
            .sink { [weak self] in
                self?.performLogout()
            }
            .store(in: &cancellables)
    }
    
    private func performLogout() {
        output.isLoading.send(true)
        
        userService.signOut { [weak self] result in
            guard let self else { return }
            self.output.isLoading.send(false)
            
            switch result {
            case .success():

                self.userManager.updateUser(user: nil)
                
                self.output.logoutCompleted.send(())
            case .failure(let error):
                self.output.errorMessage.send(error.localizedDescription)
            }
        }
    }
}
