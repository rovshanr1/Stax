//
//  WorkoutCoordinatorFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.07.26.
//

import UIKit


protocol WorkoutCoordinatorFactory{
    func makeWorkoutVC() -> WorkoutVC
    
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutId: String?) -> WorkoutSessionCoordinator
}

struct DefaultWorkoutModuleFactory: WorkoutCoordinatorFactory {
    let dependency: AppDependencies
    
    func makeWorkoutVC() -> WorkoutVC {
        WorkoutVC()
    }
    
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutId: String?) -> WorkoutSessionCoordinator {
        let sessionFactory = DefaultWorkoutSessionFactory(dependency: dependency)
        return WorkoutSessionCoordinator(navigationController, factory: sessionFactory, workoutId: workoutId)
    }
}
