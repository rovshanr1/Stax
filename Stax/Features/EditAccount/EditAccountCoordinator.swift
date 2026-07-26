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
    
    private var vm: EditAccountVM
    private var appDIContainer: AppDependencies
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(navigationController: UINavigationController, appDIContainer: AppDependencies){
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
        
        self.vm = EditAccountVM(userManager: appDIContainer.userManager)
    }
    
    func start() {
        let editAccountVC = EditAccountVC(viewModel: vm)
        
        editAccountVC.didSentEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        handleNavigation()
        
        navigationController.pushViewController(editAccountVC, animated: true)
    }
    
    private func handleNavigation(){
        vm.output.itemsOnTapped
            .receive(on: DispatchQueue.main)
            .sink { [weak self] editAccountEvent in
                self?.handle(editAccountEvent)
            }
            .store(in: &cancellables)
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
        let chnageEmailVM = ChangeEmailVM(userManager: appDIContainer.userManager)
        let changeEmailVC = ChangeEmailVC(viewModel: chnageEmailVM)
        
        changeEmailVC.navigationItem.largeTitleDisplayMode = .never
        
        changeEmailVC.onFinish = {[weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(changeEmailVC, animated: true)
    }
    
    private func handleChangeUsername(){
        let chnageUserNameVM = ChangeUserNameVM(userManager: appDIContainer.userManager)
        
        let chnageUserNameVC = ChangeUserNameVC(viewModel: chnageUserNameVM)
        
        chnageUserNameVC.navigationItem.largeTitleDisplayMode = .never
        
        chnageUserNameVC.onFinish = {[weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(chnageUserNameVC, animated: true)
        
    }
    
    private func handleUserPassword(){
        let changePasswordVM = ChangePasswordVM()
        let chnagePasswordVC = ChangePasswordVC(viewModel: changePasswordVM)
        
        chnagePasswordVC.navigationItem.largeTitleDisplayMode = .never
        
        chnagePasswordVC.onFinished = {[weak self ] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(chnagePasswordVC, animated: true)
    }
    
    private func handleDeleteAccount(){
        let deleteAccountVM = DeleteAccountVM()
        let deleteAccountVC = DeleteAccountVC(viewModel: deleteAccountVM)
        
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
