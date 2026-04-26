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
    
    var type: CoordinatorType  { .editProfile }
    
    private var vm: EditProfileVM
    private let userModel: UserModel
    private let userManager: UserManager
    
    init(navigationController: UINavigationController, userModel: UserModel, userManager: UserManager){
        self.userModel = userModel
        self.navigationController = navigationController
        self.userManager = userManager
        
        self.vm = EditProfileVM(userModel: userModel, userManager: userManager)
    }
    
    func start() {
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
