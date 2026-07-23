//
//  HomeModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 17.07.26.
//

import UIKit

protocol HomeCoordinatorFactory{
    func makeHomeViewController() -> HomeVC
    
    //Child
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutId: String?) -> WorkoutSessionCoordinator
    func makeWorkoutDetailCoordinator(navigationController: UINavigationController, workoutId: String) -> WorkoutDetailCoordinator
}

struct DefaultHomeModuleFactory: HomeCoordinatorFactory{
    
    let appDIContainer: AppDIContainer
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    func makeHomeViewController() -> HomeVC {
        let vm = HomeVM(
            workoutRepo: appDIContainer.sharedWorkoutRepo,
            shareService: appDIContainer.shareService,
            synService: appDIContainer.sharedFirebaseService)
        
        let vc = HomeVC(vm: vm)
        
        return vc
    }
    
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutId: String?) -> WorkoutSessionCoordinator {
        return WorkoutSessionCoordinator(navigationController, appDIContainer: appDIContainer, workoutId: workoutId)
    }
    
    func makeWorkoutDetailCoordinator(navigationController: UINavigationController, workoutId workoutID: String) -> WorkoutDetailCoordinator {
        return WorkoutDetailCoordinator(navigationController: navigationController, appDIContainer: appDIContainer, workoutID: workoutID)
    }
}
