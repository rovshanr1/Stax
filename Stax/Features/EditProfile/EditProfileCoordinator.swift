//
//  EditProfileCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.04.26.
//

import UIKit

enum EditProfileEvent{
    case dismiss
    case saveChanges
}

final class EditProfileCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let appDIContainer: AppDependencies
  
    
    init(navigationController: UINavigationController, appDIContainer: AppDependencies){
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        
        let vm = EditProfileVM(userManager: appDIContainer.userManager)

        let editProfileVC = EditProfileVC(vm: vm)
        
        editProfileVC.didSentEventClosure = {[weak self] event in
            self?.handle(event)
        }
        
        editProfileVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(editProfileVC, animated: true)
    }
    
    private func handle(_ event: EditProfileEvent){
        switch event{
        case .dismiss:
            finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        case .saveChanges:
            navigationController.popViewController(animated: true)
            finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        }
    }
    
}

extension EditProfileCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}
