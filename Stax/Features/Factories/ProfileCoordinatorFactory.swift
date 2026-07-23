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
    func makeSettingsCoordinates(navigationController: UINavigationController) -> SettingsCoordinator
    func makeEditProfileCoordinator(navigationController: UINavigationController) -> EditProfileCoordinator
    func makeWorkoutDetailCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutDetailCoordinator
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutSessionCoordinator
}

struct DefaultProfileModuleFactory: ProfileCoordinatorFactory {
    let appDIContainer: AppDIContainer
    
    
    func makeProfileViewController() -> ProfileVC {
        let vm = ProfileVM(
            workoutRepo: appDIContainer.sharedWorkoutRepo,
            userManger: appDIContainer.userManager)
        
        return ProfileVC(viewModel: vm)
    }
    
    func makeSettingsCoordinates(navigationController: UINavigationController) -> SettingsCoordinator {
        SettingsCoordinator(navigationController, appDIContainer: appDIContainer)
    }
    
    func makeEditProfileCoordinator(navigationController: UINavigationController) -> EditProfileCoordinator {
        EditProfileCoordinator(navigationController: navigationController, appDIContainer: appDIContainer)
    }
    
    func makeWorkoutDetailCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutDetailCoordinator {
        WorkoutDetailCoordinator(navigationController: navigationController, appDIContainer: appDIContainer, workoutID: workoutID)
    }
    
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutID: String) -> WorkoutSessionCoordinator {
        WorkoutSessionCoordinator(navigationController, appDIContainer: appDIContainer, workoutId: workoutID)
    }
    
    
}
