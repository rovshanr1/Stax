//
//  ProfileCoordinatorFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.07.26.
//

import UIKit

protocol ProfileCoordinatorFactory{
    func makeProfileViewController() -> ProfileVC
    
    //Child
    func makeSettingsCoordinator(navigationController: UINavigationController) -> SettingsCoordinator
    func makeEditProfileCoordinator(navigationController: UINavigationController) -> EditProfileCoordinator
    func makeWorkoutDetailCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutDetailCoordinator
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutSessionCoordinator
}

struct DefaultProfileModuleFactory: ProfileCoordinatorFactory {
    let dependency: AppDependencies
    
    
    func makeProfileViewController() -> ProfileVC {
        let vm = ProfileVM(
            workoutRepo: dependency.sharedWorkoutRepo,
            userManger: dependency.userManager)
        
        return ProfileVC(viewModel: vm)
    }
    
    func makeSettingsCoordinator(navigationController: UINavigationController) -> SettingsCoordinator {
        let factory = DefaultSettingsCoordinatorFactory(dependency: dependency)
        return SettingsCoordinator(navigationController, factory: factory, dependency: dependency)
    }
    
    func makeEditProfileCoordinator(navigationController: UINavigationController) -> EditProfileCoordinator {
        let factory = DefaultEditProfileModuleFactory(dependency: dependency)
        return EditProfileCoordinator(navigationController: navigationController, factory: factory)
    }
    
    func makeWorkoutDetailCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutDetailCoordinator {
        WorkoutDetailCoordinator(navigationController: navigationController, appDIContainer: dependency, workoutID: workoutID)
    }
    
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutSessionCoordinator {
        WorkoutSessionCoordinator(navigationController, dependency: dependency, workoutId: workoutID)
    }
    
    
}
