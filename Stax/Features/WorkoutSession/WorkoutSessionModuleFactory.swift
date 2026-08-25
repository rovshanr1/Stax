//
//  WorkoutSessionModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.08.26.
//

import UIKit

protocol WorkoutSessionCoordinatorFactory{
    func makeWorkoutSessionVC(workoutID: String?) -> WorkoutSessionVC
    
    func makeExerciseListCoordinator(navigationController: UINavigationController) -> ExerciseListCoordinator
    func makeWorkoutSummaryCoordinator(navigationController: UINavigationController, workoutID: String, stats: WorkoutStats) -> WorkoutSummaryCoordinator
    
}

struct DefaultWorkoutSessionFactory: WorkoutSessionCoordinatorFactory {
    
    let dependency: AppDependencies
    
    func makeWorkoutSessionVC(workoutID: String?) -> WorkoutSessionVC {
        let viewModel = WorkoutSessionViewModel(sessionService: dependency.sharedSessionService, workoutId: workoutID)
        
        let viewController = WorkoutSessionVC(viewModel: viewModel)
        
        return viewController
    }
    
    func makeExerciseListCoordinator(navigationController: UINavigationController) -> ExerciseListCoordinator {
        let exerciseFactory = DefaultExerciseListFactory(appDependencies: dependency)
        return ExerciseListCoordinator(navigationController, factory: exerciseFactory)
    }
    
    func makeWorkoutSummaryCoordinator(navigationController: UINavigationController, workoutID: String, stats: WorkoutStats) -> WorkoutSummaryCoordinator {
        let summaryFactory = DefaultWorkoutSummaryFactory(dependency: dependency)
        return WorkoutSummaryCoordinator(navigationController: navigationController, factory: summaryFactory, workoutID: workoutID, stats: stats)
    }
}
