//
//  WorkoutSetCompletionResolver.swift
//  Stax
//
//  Created by Rovshan Rasulov on 14.08.26.
//

import Foundation

enum WorkoutSetCompletionResolver {
    struct ResolvedValues {
        let weight: Double
        let reps: Int
    }
    
    static func resolve(
        weight: Double,
        reps: Int,
        isDone: Bool,
        exerciseType: ExerciseType,
        previousWeight: Double?,
        previousReps: Int16?
    ) -> ResolvedValues? {
        guard isDone else {
            return ResolvedValues(weight: weight, reps: reps)
        }
        
        var finalReps = reps
        if finalReps == 0, let previousReps {
            finalReps = Int(previousReps)
        }
        
        guard exerciseType.requiresWeight else {
            guard finalReps != 0 else { return nil }
            return ResolvedValues(weight: 0, reps: finalReps)
        }
        
        var finalWeight = weight
        if finalWeight == 0, let previousWeight {
            finalWeight = previousWeight
        }
        
        guard finalWeight != 0, finalReps != 0 else { return nil }
        
        return ResolvedValues(weight: finalWeight, reps: finalReps)
    }
}

