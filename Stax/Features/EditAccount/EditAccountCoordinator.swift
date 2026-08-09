//
//  EditAccountCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import UIKit
import Combine

//MARK: - Delegation
protocol EditAccountCoordinatorDelegate: AnyObject {
    func editAccountCoordinatorDidDeleteAccount()
}

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
    
    //Delegate
    weak var editDelegate: EditAccountCoordinatorDelegate?
    
    //Factory
    private let factory: EditAccountCoordinatorFactory
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(navigationController: UINavigationController, factory: EditAccountCoordinatorFactory){
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {
        let editAccountVC = factory.makeEditAccountViewController()
        
        editAccountVC.coordinatorEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        navigationController.pushViewController(editAccountVC, animated: true)
    }
    
    private func handle(_ event: EditAccountEvent) {
        switch event{
            
        case .changeUsername:
            handleChangeUsername()
        case .changePassword:
            handleUserPassword()
        case .changeEmail:
            handleChangeEmail()
        case .deleteAccount:
            handleDeleteAccount()
        case .dismiss:
            finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        }
    }
    
  
    //MARK: - Views Handling
    
    private func handleChangeEmail(){
        let changeEmailVC = factory.makeChangeEmail()
        
        changeEmailVC.navigationItem.largeTitleDisplayMode = .never
        
        changeEmailVC.onFinish = {[weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(changeEmailVC, animated: true)
    }
    
    private func handleChangeUsername(){
        let chnageUserNameVC = factory.makeChangeUserName()
        
        chnageUserNameVC.navigationItem.largeTitleDisplayMode = .never
        
        chnageUserNameVC.onFinish = {[weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(chnageUserNameVC, animated: true)
        
    }
    
    private func handleUserPassword(){
        let chnagePasswordVC = factory.makeChangePassword()
        
        chnagePasswordVC.navigationItem.largeTitleDisplayMode = .never
        
        chnagePasswordVC.onFinished = {[weak self ] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(chnagePasswordVC, animated: true)
    }
    
    private func handleDeleteAccount(){
        let deleteAccountVC = factory.makeDeleteAccount()
        
        deleteAccountVC.navigationItem.largeTitleDisplayMode = .never
        
        let modalNavController = UINavigationController(rootViewController: deleteAccountVC)
        
        modalNavController.modalPresentationStyle = .fullScreen
        modalNavController.modalTransitionStyle = .coverVertical
        
        deleteAccountVC.onDismiss = { [weak self] in
            self?.navigationController.presentedViewController?.dismiss(animated: true)
        }
        
        deleteAccountVC.onDeletionSuccess = {[weak self] in
            self?.navigationController.presentedViewController?.dismiss(animated: true){
                self?.editDelegate?.editAccountCoordinatorDidDeleteAccount()
            }
        }
        
        navigationController.present(modalNavController, animated: true)
    }
    
    
}

extension EditAccountCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: any Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}
