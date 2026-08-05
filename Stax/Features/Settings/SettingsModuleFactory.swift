//
//  SettingsModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.08.26.
//

import UIKit

protocol SettingsCoordinatorFactory{
    func makeSettingViewController() -> SettingsVC
    
    //child
    func makeEditProfileCoordinator(navigationController: UINavigationController) -> EditProfileCoordinator
    func makeEditAccountCoordinator(navigationConroller: UINavigationController) -> EditAccountCoordinator
}

struct DefaultSettingsCoordinatorFactory: SettingsCoordinatorFactory {
  
    let dependency: AppDependencies
    
    init(dependency: AppDependencies) {
        self.dependency = dependency
    }
    
    func makeSettingViewController() -> SettingsVC {
        let viewModel = SettingsVM(userManager: dependency.userManager)
        let viewController = SettingsVC(vm: viewModel)
        
        return viewController
    }
    
    func makeEditProfileCoordinator(navigationController: UINavigationController) -> EditProfileCoordinator {
        EditProfileCoordinator(navigationController: navigationController, dependency: dependency)
    }
    
    func makeEditAccountCoordinator(navigationConroller: UINavigationController) -> EditAccountCoordinator {
        EditAccountCoordinator(navigationController: navigationConroller, dependency: dependency)
    }
    
}
