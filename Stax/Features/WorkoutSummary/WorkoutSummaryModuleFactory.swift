//
//  WorkoutSummaryModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 12.08.26.
//

import UIKit

protocol WorkoutSummaryCoordinatorFactory {
    func makeWorkoutSummaryVC(workoutID: String, stats: WorkoutStats) -> WorkoutSummaryVC
}

struct DefaultWorkoutSummaryFactory: WorkoutSummaryCoordinatorFactory{
    let dependency: AppDependencies
    
    func makeWorkoutSummaryVC(workoutID: String, stats: WorkoutStats) -> WorkoutSummaryVC {
        let viewModel = WorkoutSummaryViewModel(workoutID: workoutID, workoutRepository: dependency.genericWorkoutRepo, stats: stats, dependency: dependency)
        let viewController = WorkoutSummaryVC(viewModel: viewModel)
        
        return viewController
    }
}
