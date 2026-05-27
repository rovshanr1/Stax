//
//  SettingsCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit
import Combine

protocol SettingsCoordinatorDelegate: CoordinatorFinishDelegate {
    func settingsCoordinatorDidLogout()
}

//MARK: - Event Enums
enum SettingsEvent {
    case logout
    case dismiss
}

enum AccountEvent{
    case editProfile
    case editAccount
}



final class SettingsCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    //Delegate
    weak var settingsDelegate: SettingsCoordinatorDelegate?
    
    //ViewModel
    private let settingsVM: SettingsVM
    
    //Container
    let appDIContainer: AppDIContainer
    
    private var cancellables: Set<AnyCancellable> = []

    
    init(_ navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
        
        self.settingsVM = SettingsVM(userManager: appDIContainer.userManager)
    }
    
    func start() {
        let settingsVC = SettingsVC(vm: settingsVM)
        
        
        settingsVC.didSentEventClosure = { [weak self] event in
            guard let self = self else { return }
            self.handle(event)
        }
        
        settingsVC.hidesBottomBarWhenPushed = true
        
        handleNavigation()

        navigationController.pushViewController(settingsVC, animated: true)
    }
    
    private func handle(_ event: SettingsEvent) {
        switch event{
 
        case .dismiss:
            navigationController.popViewController(animated: true)
            finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        case .logout:
            settingsDelegate?.settingsCoordinatorDidLogout()
            finishDelegate?.coordinatorDidFinish(childCoordinator: self)
      
        }
    }
    
    private func handleNavigation(){
        settingsVM.output.preferencesOnTapped
            .receive(on: DispatchQueue.main)
            .sink { [weak self] serviceEvent in
                self?.handlePreferencies(serviceEvent)
            }
            .store(in: &cancellables)
    }
    
    private func handlePreferencies(_ event: AccountEvent) {
        switch event{
        case .editProfile:
            profileScreen()
        case .editAccount:
            editAccountScreen()
        }
    }
    
    
    //MARK: - Profile Screen
    
    private func profileScreen() {
        guard let currentUser = settingsVM.output.userInfo.value else { return }
        
        let coordinator = EditProfileCoordinator(navigationController: navigationController, appDIContainer: appDIContainer, userModel: currentUser)
       
        coordinator.finishDelegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    //MARK: - EdditAccount Scrren
    private func editAccountScreen() {
        guard let currentUser = settingsVM.output.userInfo.value else { return }

        
        let coordinator = EditAccountCoordinator(navigationController: navigationController, appDIContainer: appDIContainer, userModel: currentUser)
        
        coordinator.finishDelegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
}


extension SettingsCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}


