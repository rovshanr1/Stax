//
//  SettingsVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import Foundation
import Combine

nonisolated enum SettingsItemIdentity: Sendable{
    case editProfile
    case editAccount
    case healthKit
    case logout
}

final class SettingsVM {
    
    struct Input {
        let viewDidLoad: PassthroughSubject<Void, Never>
        let itemTapped: PassthroughSubject<SettingsItem, Never>
        let logoutTapped: PassthroughSubject<Void, Never>
        let toggleHealthKit: PassthroughSubject<Bool, Never>
    }
    
    struct Output {
        let userInfo: CurrentValueSubject<UserModel?, Never>
        let errorMessage: PassthroughSubject<String, Never>
        let isLoading: CurrentValueSubject<Bool, Never>
        let settingData: CurrentValueSubject<[(SettingsSection, [SettingsItem])], Never>
        let preferencesOnTapped: PassthroughSubject<AccountEvent, Never>
        let isHealthKitSyncEnabled: CurrentValueSubject<Bool, Never>
        let logoutCompleted: PassthroughSubject<Void, Never>
    }
    
    let input: Input
    let output: Output
    
    private var cancellables: Set<AnyCancellable> = []
    
    //Services
    private let userService: UserServiceProtocol
    private let userManager: UserManager
    private let healthKitManager: HealthKitServiceInterface
    private var preferencesService: AppPreferencesServiceInterface
    
    init(userService: UserServiceProtocol = UserService(),
         userManager: UserManager,
         healthKitManager: HealthKitServiceInterface = HealthKitService(),
         preferancesService: AppPreferencesServiceInterface = AppPreferencesService()
    ) {
        self.userService = userService
        self.userManager = userManager
        self.healthKitManager = healthKitManager
        self.preferencesService = preferancesService
        
        self.input = .init(viewDidLoad: .init(),
                           itemTapped: .init(),
                           logoutTapped: . init(),
                           toggleHealthKit: .init()
                           
        )
        
        self.output = .init(userInfo: .init(nil),
                            errorMessage: .init(),
                            isLoading: .init(false),
                            settingData: .init([]),
                            preferencesOnTapped: .init(),
                            isHealthKitSyncEnabled: .init(false),
                            logoutCompleted: .init()
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
        
        input.itemTapped
            .sink { [weak self] item in
                self?.handleItemTap(item)
            }
            .store(in: &cancellables)
        
        input.logoutTapped
            .sink { [weak self] in
                self?.performLogout()
            }
            .store(in: &cancellables)
        
        input.toggleHealthKit
            .sink { [weak self] isEnabled in
                self?.healthKitSyncStatus(isEnabled)
            }
            .store(in: &cancellables)
        
    }
    
    //MARK: - Diffable Data
    private func buildSettingsData() {
        var data: [(SettingsSection, [SettingsItem])] = []
        
        let accountItems: [SettingsItem] = [
            .navigation(id: .editProfile, icon: "person.fill", title: "Profile", color: "#707173"),
            .navigation(id: .editAccount, icon: "lock.fill", title: "Account", color: "#707173")
        ]
        data.append((.account, accountItems))
        
        let preferenceItems: [SettingsItem] = [
            .toggle(id: .healthKit, icon: "heart.fill", title: "Apple Health", isOn: false, color: "#FF3953")
        ]
        data.append((.preferences, preferenceItems))
        
       
        
        let logoutItem: [SettingsItem] = [
            .logout(id: .logout, title: "Logout")
        ]
        data.append((.logout, logoutItem ))
        
        
        output.settingData.send(data)
    }
    
    //MARK: - Handle events
    private func handleItemTap(_ item: SettingsItem){
        switch item{
        case .navigation(let id, _, _, _):
            switch id{
            case .editProfile:
                output.preferencesOnTapped.send(.editProfile)
            case .editAccount:
                output.preferencesOnTapped.send(.editAccount)
                
            default:
                break
            }
        
        case .toggle(let id, _, _, let isOn, _):
            if id == .healthKit {
                input.toggleHealthKit.send(!isOn)
            }
            
        case .logout(let id, _):
            switch id {
            case .logout:
                performLogout()
                
            default:
                break
            }
        }
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
    
    private func healthKitSyncStatus(_ isEnabled: Bool) {
        if isEnabled{
            self.healthKitManager.requestAuthorization { [weak self] success, error in
                guard let self else {return}
                
                if success {
                    self.preferencesService.isHealthKitSyncEnabled = true
                    self.output.isHealthKitSyncEnabled.send(true)
                }else{
                    print("HealhKit Authorization Failed: \(error?.localizedDescription ?? "Unknown Error")")
                    self.preferencesService.isHealthKitSyncEnabled = false
                    self.output.isHealthKitSyncEnabled.send(false)
                }
            }
        }else{
            self.preferencesService.isHealthKitSyncEnabled = false
            self.output.isHealthKitSyncEnabled.send(false)
        }
    }
}
