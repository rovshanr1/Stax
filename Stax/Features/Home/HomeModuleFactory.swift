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
    
    let dependency: AppDependencies
    
    init(dependency: AppDependencies) {
        self.dependency = dependency
    }
    
    func makeHomeViewController() -> HomeVC {
        let vm = HomeVM(
            workoutRepo: dependency.sharedWorkoutRepo,
            shareService: dependency.shareService,
            synService: dependency.sharedFirebaseService)
        
        let vc = HomeVC(vm: vm)
        
        return vc
    }
    
    func makeWorkoutSessionCoordinator(navigationController: UINavigationController, workoutId: String?) -> WorkoutSessionCoordinator {
        let factory = DefaultWorkoutSessionFactory(dependency: dependency)
        return WorkoutSessionCoordinator(navigationController, factory: factory, workoutId: workoutId)
    }
    
    func makeWorkoutDetailCoordinator(navigationController: UINavigationController, workoutId workoutID: String) -> WorkoutDetailCoordinator {
        let factory = DefaultWorkoutDetailFactory(dependency: dependency)
        return WorkoutDetailCoordinator(navigationController: navigationController, factory: factory, workoutID: workoutID)
    }
}
