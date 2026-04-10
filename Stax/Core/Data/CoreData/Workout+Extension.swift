//
//  Workout+Extension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation
import CoreData

extension Workout{
    func toDomain() -> WorkoutDomainModel{
        let exercisesSet = self.workoutExercises as? Set<WorkoutExercise> ?? []
        let sortedExerciseDomain = exercisesSet
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .map { $0.toDomain() }
        
        
        return WorkoutDomainModel(
            id: self.id?.uuidString ?? UUID().uuidString,
            name: self.name ?? "Unknown Wokrout",
            duration: self.duration,
            volume: self.volume,
            workoutDescription: self.workoutDescription,
            date: self.date ?? Date(),
            caloriesBurned: self.calories,
            sets: self.sets,
            workoutExercises: sortedExerciseDomain)
    }
}
