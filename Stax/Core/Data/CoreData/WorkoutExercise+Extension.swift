//
//  WorkoutExercise+Extension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation
import CoreData

extension WorkoutExercise{
    func toDomain() -> WorkoutExerciseDomainModel{
        let exerciseDomain = self.exercise?.toDomain()
        
        let setsSet = self.workoutSets as? Set<WorkoutSet> ?? []
        let sortedSetsDomain = setsSet
            .sorted { $0.orderIndex < $1.orderIndex}
            .map { $0.toDomain() }
        
        return WorkoutExerciseDomainModel(
            id: self.objectID.uriRepresentation().absoluteString,
            notes: self.note,
            orderIndex: self.orderIndex,
            exercise: exerciseDomain,
            workoutSets: sortedSetsDomain
        )
    }
    
}
