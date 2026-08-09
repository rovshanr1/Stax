//
//  WorkoutDetailModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.08.26.
//

import UIKit

protocol WorkoutDetailCoordinatorFactory{
    func makeWorkoutDetailVC(workoutID: String) -> WorkoutDetailVC
}

struct DefaultWorkoutDetailFactory: WorkoutDetailCoordinatorFactory {
    let dependency: AppDependencies
    
    init(dependency: AppDependencies) {
        self.dependency = dependency
    }
    
    func makeWorkoutDetailVC(workoutID: String) -> WorkoutDetailVC {
        let viewModel = WorkoutDetailVM(workoutID: workoutID, workoutRepo: dependency.sharedWorkoutRepo)
        let vc = WorkoutDetailVC(viewModel: viewModel)
        return vc
    }
}
