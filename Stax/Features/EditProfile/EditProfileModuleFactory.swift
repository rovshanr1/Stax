//
//  EditProfileModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.08.26.
//

import Foundation

protocol EditProfileCoordinatorFactory{
    func makeEditProfileViewController() -> EditProfileVC
}

struct DefaultEditProfileModuleFactory: EditProfileCoordinatorFactory {
    let dependency: AppDependencies
    
    func makeEditProfileViewController() -> EditProfileVC {
        let viewModel = EditProfileVM(userManager: dependency.userManager)
        let viewController = EditProfileVC(vm: viewModel)
        
        return viewController
    }
}
