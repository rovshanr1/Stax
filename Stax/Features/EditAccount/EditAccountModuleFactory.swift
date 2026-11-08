//
//  EditAccountModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.08.26.
//

import UIKit

protocol EditAccountCoordinatorFactory{
    func makeEditAccountViewController() -> EditAccountVC
    
    func makeChangeEmail() -> ChangeEmailVC
    func makeChangeUserName() -> ChangeUserNameVC
    func makeChangePassword() -> ChangePasswordVC
    func makeDeleteAccount() -> DeleteAccountVC
}

struct DefaultEditAccountModuleFactory: EditAccountCoordinatorFactory{
    
    let dependency: AppDependencies
    
    init(dependency: AppDependencies) {
        self.dependency = dependency
    }
    
    func makeEditAccountViewController() -> EditAccountVC {
        let viewModel = EditAccountVM(userManager: dependency.userManager)
        let viewController = EditAccountVC(viewModel: viewModel)
        
        return viewController
    }
    
    func makeChangeEmail() -> ChangeEmailVC {
        let viewModel = ChangeEmailVM(userManager: dependency.userManager)
        let viewController = ChangeEmailVC(viewModel: viewModel)
        
        return viewController
    }
    
    func makeChangeUserName() -> ChangeUserNameVC {
        let viewModel = ChangeUserNameVM(userManager: dependency.userManager)
        let viewController = ChangeUserNameVC(viewModel: viewModel)
        
        return viewController
    }
    
    func makeChangePassword() -> ChangePasswordVC {
        let viewModel = ChangePasswordVM()
        let viewController = ChangePasswordVC(viewModel: viewModel)
        
        return viewController
    }
    
    func makeDeleteAccount() -> DeleteAccountVC {
        let viewModel = DeleteAccountVM()
        let viewController = DeleteAccountVC(viewModel: viewModel)
        
        return viewController
    }
}

