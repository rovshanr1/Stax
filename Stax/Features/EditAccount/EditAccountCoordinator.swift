//
//  EditAccountCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import UIKit
import Combine

enum EditAccountEvent{
    case changeUsername
    case changePassword
    case changeEmail
    case deleteAccount
    case dismiss
}

final class EditAccountCoordinator: Coordinator{
    var finishDelegate: (CoordinatorFinishDelegate)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var vm: EditAccountVM
    private var appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController, appDIContainer: AppDIContainer){
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
        
        self.vm = EditAccountVM(userManager: appDIContainer.userManager)
    }
    
    func start() {
        let editAccountVC = EditAccountVC(viewModel: vm)
        
        editAccountVC.didSentEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        navigationController.pushViewController(editAccountVC, animated: true)
    }
    
    private func handle(_ event: EditAccountEvent) {
        switch event{
            
        case .changeUsername:
            print("Soon")
        case .changePassword:
            print("Soon")
        case .changeEmail:
            print("Soon")
        case .deleteAccount:
            print("Soon")
        case .dismiss:
            finishDelegate?.coordinatorDidFinish(childCoordinator: self)
            print("this page dismissid")
        }
    }
    
    
    private func handleUserNameView(){
        let _ = ChangeUserNameVC()
        
        
    }
}

extension EditAccountCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: any Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}
