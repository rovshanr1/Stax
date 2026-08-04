//
//  ExerciseListCoordinatorFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.08.26.
//

import UIKit

protocol ExerciseListCoordinatorFactory{
    func makeExerciseList() -> ExerciseListVC
}


struct DefaultExerciseListFactory: ExerciseListCoordinatorFactory {
    private let appDependencies: AppDependencies
    
    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
    }
    
    func makeExerciseList() -> ExerciseListVC {
        let exerciseListVM = ExerciseListVM(repository: appDependencies.sharedExerciseDefRepo)
        let exerciseLitsVC = ExerciseListVC(viewModel: exerciseListVM)
        
        return exerciseLitsVC
    }
}
