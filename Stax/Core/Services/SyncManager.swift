//
//  SyncManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.04.26.
//

import Foundation
import Combine
import CoreData

protocol SyncManagerInterface{
    func saveCloudWorkoutToLocal(cloudWorkout: WorkoutDomainModel)
}

final class SyncManager: SyncManagerInterface{
    
    private var workoutRepo: DataRepository<Workout>
    private let exerciseRepo: DataRepository<WorkoutExercise>
    private let setRepo: DataRepository<WorkoutSet>
    private let exercise: DataRepository<Exercise>
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(workoutRepo: DataRepository<Workout>,
         exerciseRepo: DataRepository<WorkoutExercise>,
         setRepo: DataRepository<WorkoutSet>,
         exercise: DataRepository<Exercise>
    ) {
        
        self.workoutRepo = workoutRepo
        self.exerciseRepo = exerciseRepo
        self.setRepo = setRepo
        self.exercise = exercise
    }
    func saveCloudWorkoutToLocal(cloudWorkout: WorkoutDomainModel) {
        
        let localWorkout = workoutRepo.fetch(by: cloudWorkout.id) ?? workoutRepo.create()
        
        localWorkout.id = UUID(uuidString: cloudWorkout.id)
        localWorkout.name = cloudWorkout.name
        localWorkout.duration = cloudWorkout.duration
        localWorkout.volume = cloudWorkout.volume
        localWorkout.workoutDescription = cloudWorkout.workoutDescription
        localWorkout.date = cloudWorkout.date
        localWorkout.calories = cloudWorkout.caloriesBurned
        localWorkout.sets = cloudWorkout.sets
        
        
        
        if let oldExercises = localWorkout.workoutExercises as? Set<WorkoutExercise> {
            for oldEx in oldExercises{
                exerciseRepo.delete(oldEx)
                    .sink(receiveCompletion: {_ in}, receiveValue: {_ in})
                    .store(in: &cancellables)
            }
        }
        
        for cloudExercise in cloudWorkout.workoutExercises {
            let localExercise = exerciseRepo.create()
            
            localExercise.id = UUID(uuidString: cloudExercise.id)
            localExercise.note = cloudExercise.notes
            localExercise.orderIndex = Int16(cloudExercise.orderIndex)
            localExercise.workout = localWorkout // İdmana bağladık!
            
            // 🔥 EKSİK 2: Temel hareketi ansiklopediden bul ve bağla
            if let baseExerciseId = cloudExercise.exercise?.id,
               let baseExercise = exercise.fetch(by: baseExerciseId) {
                localExercise.exercise = baseExercise
            }
            
            // 🔥 EKSİK 3: Setleri Dön (Nested Loop)
            for cloudSet in cloudExercise.workoutSets {
                let localSet = setRepo.create()
                
                localSet.id = UUID(uuidString: cloudSet.id)
                localSet.weight = cloudSet.weight
                localSet.reps = Int16(cloudSet.reps)
                localSet.isComplated = cloudSet.isCompleted
                localSet.orderIndex = Int16(cloudSet.orderIndex)
                localSet.previous = cloudSet.previous 
                localSet.restTime = cloudSet.restTime ?? 0.0
                
                localSet.workoutExercise = localExercise
            }
        }
        
        workoutRepo.save()
            .sink(receiveCompletion: {_ in}, receiveValue: {_ in})
            .store(in: &cancellables)
    }
}


