//
//  SettingsCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit

protocol SettingsCoordinatorDelegate: CoordinatorFinishDelegate {
    func settingsCoordinatorDidLogout()
}

enum SettingsEvent {
    case logout
    case dismiss
}

final class SettingsCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .settings }
    
    //Delegate
    weak var settingsDelegate: SettingsCoordinatorDelegate?
    
    //Private properties
    private let userManager: UserManager
    private let settingsVM: SettingsVM
   
    
    init(_ navigationController: UINavigationController, userManager: UserManager) {
        self.navigationController = navigationController
        self.userManager = userManager
        
        self.settingsVM = SettingsVM(userManager: userManager)
    }
    
    func start() {
        let settingsVC = SettingsVC(vm: settingsVM)
        
        
        settingsVC.didSentEventClosure = { [weak self] event in
            guard let self = self else { return }
            self.handle(event)
        }
        

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
}


extension SettingsCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}


