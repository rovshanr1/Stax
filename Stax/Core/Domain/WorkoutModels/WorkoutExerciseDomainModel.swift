//
//  WorkoutExerciseDomainModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation

nonisolated struct WorkoutExerciseDomainModel: Hashable, Codable, Sendable {
    let id: String
    let notes: String?
    let orderIndex: Int16
    
    //relationships
    let exercise: ExerciseDomainModel?
    let workoutSets: [WorkoutSetDomainModel]
}
