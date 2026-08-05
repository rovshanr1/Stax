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
    case preferencesOnTapped(event: AccountEvent)
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
    
    //Container
    let dependency: AppDependencies
    //Factory
    private let factory: SettingsCoordinatorFactory
    
    private var cancellables: Set<AnyCancellable> = []

    
    init(_ navigationController: UINavigationController, factory: SettingsCoordinatorFactory, dependency: AppDependencies) {
        self.navigationController = navigationController
        self.factory = factory
        self.dependency = dependency
    }
    
    func start() {
        let settingsVC = factory.makeSettingViewController()
        
        settingsVC.didSentEventClosure = { [weak self] event in
            guard let self = self else { return }
            self.handle(event)
        }
        
        settingsVC.hidesBottomBarWhenPushed = true

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
        case .preferencesOnTapped(let accountEvent):
            handlePreferencies(accountEvent)
        }
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
        let coordinator = factory.makeEditProfileCoordinator(navigationController: navigationController)
       
        coordinator.finishDelegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    //MARK: - EdditAccount Scrren
    private func editAccountScreen() {
        let coordinator = factory.makeEditAccountCoordinator(navigationConroller: navigationController)
        
        coordinator.finishDelegate = self
        coordinator.editDelegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
}


extension SettingsCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}

extension SettingsCoordinator: EditAccountCoordinatorDelegate {
    func editAccountCoordinatorDidDeleteAccount() {
        settingsDelegate?.settingsCoordinatorDidLogout()
        
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}


