//
//  WorkoutSessionError.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.12.25.
//

import Foundation

enum WorkoutSessionError: Error {
    case noAddExercise
    
    var description: String? {
        switch self {
        case .noAddExercise:
            return "No add exercise"
        }
    }
}
