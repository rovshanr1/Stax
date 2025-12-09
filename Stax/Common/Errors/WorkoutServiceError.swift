//
//  WorkoutServiceError.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.12.25.
//

import Foundation

enum WorkoutServiceError: Error {
    case noAddExercise
    
    var description: String? {
        switch self {
        case .noAddExercise:
            return "No add exercise"
        }
    }
}
