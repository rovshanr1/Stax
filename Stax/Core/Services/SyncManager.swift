//
//  SyncManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.04.26.
//

import Foundation
import Combine
import CoreData

struct SyncRestoreResult{
    let restoredWorkouts: Int
    let skippedWorkouts: Int
    let missingExerciseDefinitions: Int
}

protocol SyncManagerInterface{
    func restoreWorkouts(_ cloudWorkouts: [WorkoutDomainModel]) throws -> SyncRestoreResult
}

final class SyncManager: SyncManagerInterface{
  
    private var workoutRepo: DataRepository<Workout>
    private let exerciseRepo: DataRepository<WorkoutExercise>
    private let setRepo: DataRepository<WorkoutSet>
    private let exerciseDefRepo: DataRepository<Exercise>
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(workoutRepo: DataRepository<Workout>,
         exerciseRepo: DataRepository<WorkoutExercise>,
         setRepo: DataRepository<WorkoutSet>,
         exercise: DataRepository<Exercise>
    ) {
        
        self.workoutRepo = workoutRepo
        self.exerciseRepo = exerciseRepo
        self.setRepo = setRepo
        self.exerciseDefRepo = exercise
    }
    
    func restoreWorkouts(_ cloudWorkouts: [WorkoutDomainModel]) throws -> SyncRestoreResult {
           let definitions = Dictionary(
               exerciseDefRepo.fetch().compactMap { definition in
                   definition.id.map { ($0, definition) }
               },
               uniquingKeysWith: { first, _ in first }
           )
    
           var restored = 0
           var skipped = 0
           var missingDefinitions = 0
    
           for cloud in cloudWorkouts {
               guard self.hasValidIDs(cloud) else {
                   skipped += 1
                   print("SyncManager: skipped workout with invalid id: \(cloud.id)")
                   continue
               }
    
               missingDefinitions += apply(cloud, definitions: definitions)
               restored += 1
           }
    
           do {
               try workoutRepo.saveNow()
           } catch {
               workoutRepo.rollback()  
               throw error
           }
    
           return SyncRestoreResult(restoredWorkouts: restored,
                                    skippedWorkouts: skipped,
                                    missingExerciseDefinitions: missingDefinitions)
       }
    
    //MARK: - Private methods
    private func hasValidIDs(_ workout: WorkoutDomainModel) -> Bool {
        guard UUID(uuidString: workout.id) != nil else { return false }
        
        return workout.workoutExercises.allSatisfy { exercise in
            UUID(uuidString: exercise.id) != nil
            && exercise.workoutSets.allSatisfy { UUID(uuidString: $0.id) != nil }
        }
    }
    
    private func apply(_ cloud: WorkoutDomainModel, definitions: [UUID: Exercise]) -> Int {
        
        let local = workoutRepo.fetch(by: cloud.id) ?? workoutRepo.create()
        
        if let id = UUID(uuidString: cloud.id) { local.id = id }
        local.name = cloud.name
        local.duration = cloud.duration
        local.volume = cloud.volume
        local.workoutDescription = cloud.workoutDescription
        local.date = cloud.date
        local.calories = cloud.caloriesBurned
        local.sets = cloud.sets
        
        for old in (local.workoutExercises as? Set<WorkoutExercise> ?? []) {
            exerciseRepo.deleteNow(old)
        }
        
        var missing = 0
        
        for cloudExercise in cloud.workoutExercises {
            let localExercise = exerciseRepo.create()
            
            if let id = UUID(uuidString: cloudExercise.id) { localExercise.id = id }
            localExercise.note = cloudExercise.notes
            localExercise.orderIndex = Int16(cloudExercise.orderIndex)
            localExercise.workout = local
            
            if let definitionID = cloudExercise.exercise?.id {
                if let uuid = UUID(uuidString: definitionID), let definition = definitions[uuid] {
                    localExercise.exercise = definition
                } else {
                    missing += 1
                    print("SyncManager: exercise definition not found: \(definitionID)")
                }
            }
            
            for cloudSet in cloudExercise.workoutSets {
                let localSet = setRepo.create()
                
                if let id = UUID(uuidString: cloudSet.id) { localSet.id = id }
                localSet.weight = cloudSet.weight
                localSet.reps = Int16(cloudSet.reps)
                localSet.isCompleted = cloudSet.isCompleted
                localSet.orderIndex = Int16(cloudSet.orderIndex)
                localSet.previous = cloudSet.previous
                localSet.restTime = cloudSet.restTime ?? 0.0
                localSet.workoutExercise = localExercise
            }
        }
        
        return missing
    }
    
}


