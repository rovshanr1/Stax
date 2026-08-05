//
//  WorkoutCoordinatorFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.07.26.
//

import UIKit


protocol WorkoutCoordinatorFactory{
    func makeWorkoutVC() -> WorkoutVC
}

struct DefaultWorkoutModuleFactory: WorkoutCoordinatorFactory {
    func makeWorkoutVC() -> WorkoutVC {
        WorkoutVC()
    }
}
