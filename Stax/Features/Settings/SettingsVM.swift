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
        let viewDidLoad: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        let logoutCompleted: PassthroughSubject<Void, Never>
        let userInfo: CurrentValueSubject<UserModel?, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
        let settingData: CurrentValueSubject<[(SettingsSection, [SettingsItem])], Never>
    }
    
    let input: Input
    let output: Output
    
    private var cancellables: Set<AnyCancellable> = []
    
    //Services
    private let userService: UserServiceProtocol
    private let userManager: UserManager
    
    init(userService: UserServiceProtocol = UserService(),
         userManager: UserManager
    ) {
        self.userService = userService
        self.userManager = userManager
        
        self.input = .init(logoutTapped: .init(),
                           viewDidLoad: .init(),
                           
        )
        
        self.output = .init(logoutCompleted: .init(),
                            userInfo: .init(nil),
                            errorMessage: .init(),
                            isLoading: .init(false),
                            settingData: .init([])
        )
        
        transform()
    }
    
    private func transform() {
        userManager.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.output.userInfo.send(user)
            }
            .store(in: &cancellables)
        
        input.viewDidLoad
            .sink { [weak self] in
                self?.buildSettingsData()
            }
            .store(in: &cancellables)
        
        input.logoutTapped
            .sink { [weak self] in
                self?.performLogout()
            }
            .store(in: &cancellables)
        
    }
    
    
    //MARK: - Helpers
    private func performLogout() {
        output.isLoading.send(true)
        
        userService.signOut { [weak self] result in
            guard let self else { return }
            self.output.isLoading.send(false)
            
            switch result {
            case .success():

                self.userManager.updateUser(nil)
                
                self.output.logoutCompleted.send(())
            case .failure(let error):
                self.output.errorMessage.send(error.localizedDescription)
            }
        }
    }
    
    private func buildSettingsData() {
        var data: [(SettingsSection, [SettingsItem])] = []
        
        let accountItems: [SettingsItem] = [
            .navigation(id: "profile", icon: "person.fill", title: "Profile", color: "#dedede")
        ]
        data.append((.account, accountItems))
        
        let preferenceItems: [SettingsItem] = [
            .toggle(id: "healthKit", icon: "heart", title: "Apple Health", isOn: false, color: "#dedede")
        ]
        data.append((.account, preferenceItems))
        
    }
}
