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
        let factory = DefaultEditProfileModuleFactory(dependency: dependency)
        return EditProfileCoordinator(navigationController: navigationController, factory: factory)
    }
    
    func makeEditAccountCoordinator(navigationConroller: UINavigationController) -> EditAccountCoordinator {
        EditAccountCoordinator(navigationController: navigationConroller, dependency: dependency)
    }
    
}
