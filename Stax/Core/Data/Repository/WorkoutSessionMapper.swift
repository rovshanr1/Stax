//
//  WorkoutSessionMapper.swift
//  Stax
//
//  Created by Rovshan Rasulov on 27.10.26.
//

import CoreData

@MainActor
enum WorkoutSessionMapper{
    struct Result {
        let exercises: [WorkoutExerciseDomainModel]
        let volume: Double
        let completedSets: Int
    }
    
    
    static func map(_ workout: Workout, previousSets: [String: [WorkoutSetDomainModel]]) -> Result{
        var volume = 0.0
        var completed = 0
        
        let cdExercises = (workout.workoutExercises as? Set<WorkoutExercise> ?? [])
                    .sorted { $0.orderIndex < $1.orderIndex }
        
        let exercises = cdExercises.compactMap { cdExercise -> WorkoutExerciseDomainModel? in
            guard let exerciseID = cdExercise.id?.uuidString else {
                assertionFailure("WorkoutExercise without id")
                return nil
            }
            
            let baseID = cdExercise.exercise?.id?.uuidString
            let past = baseID.flatMap { previousSets[$0] } ?? []
            
            let cdSets = (cdExercise.workoutSets as? Set<WorkoutSet> ?? [])
                .sorted{ $0.orderIndex < $1.orderIndex }
            
            let sets = cdSets.enumerated().compactMap { index, cdSet -> WorkoutSetDomainModel? in
                guard let setID = cdSet.id?.uuidString else {
                    assertionFailure("WorkoutSet without id")
                    return nil
                }
                
                if cdSet.isCompleted {
                    volume += cdSet.weight * Double(cdSet.reps)
                    completed += 1
                }
                
                let pastSet = index < past.count ? past[index] : nil
                
                return WorkoutSetDomainModel(
                    id: setID,
                    isCompleted: cdSet.isCompleted,
                    orderIndex: cdSet.orderIndex,
                    previous: pastSet.map(previousText) ?? "-",
                    reps: cdSet.reps,
                    restTime: cdSet.restTime,
                    weight: cdSet.weight,
                    previousWeight: pastSet?.weight,
                    previousReps: pastSet?.reps
                )
            }
            
            return WorkoutExerciseDomainModel(
                id: exerciseID,
                notes: cdExercise.note,
                orderIndex: cdExercise.orderIndex,
                exercise: cdExercise.exercise?.toDomain(),
                workoutSets: sets
            )
        }
        
        return Result(exercises: exercises, volume: volume, completedSets: completed)
    }
    
    
    private static func previousText(_ set: WorkoutSetDomainModel) -> String {
        let weight = floor(set.weight) == set.weight
        ? "\(Int(set.weight))"
        : String(format: "%.1f", set.weight)
        return "\(weight)kg x \(set.reps)"
    }
    
}
