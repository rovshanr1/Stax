//
//  WorkoutSessionService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.05.26.
//

import Foundation
import Combine

protocol SessionServiceProtocol{
    func setupSession(workoutID: String?) -> (id: String, initialDuration: Double)
    func cancelWorkoutSession()
    func finishWorkout(duration: Double)
    
    func addExercise(exerciseID: String)
    func deleteExercise(workoutExerciseID: String)
    func replaceExercise(workoutExerciseID: String, with newExerciseID: String)
    func updateExerciseNote(workoutExerciseID: String, note: String)
    
    func addNewSet(to workoutExerciseID: String)
    func updateSet(setID: String, weight: Double, reps: Int, isDone: Bool)
    func deleteSet(setID: String)
}

final class WorkoutSessionService: SessionServiceProtocol{
    
    //Repositorys
    private let exerciseRepo: DataRepository<WorkoutExercise>
    private let workoutSets: DataRepository<WorkoutSet>
    private let workoutRepo: DataRepository<Workout>
    
    //State
    private var currentWorkout: Workout?
    
    private var workoutId: String?
    
    //Combine
    private var cancellables: Set<AnyCancellable> = []
    
    init(exerciseRepo: DataRepository<WorkoutExercise>,
         workoutSets: DataRepository<WorkoutSet>,
         workoutRepo: DataRepository<Workout>) {
        self.exerciseRepo = exerciseRepo
        self.workoutSets = workoutSets
        self.workoutRepo = workoutRepo
    }
    
    func setupSession(workoutID: String?) -> (id: String, initialDuration: Double) {
        if let id = workoutID, let existingWorkout = workoutRepo.fetch(by: id) {
            self.currentWorkout = existingWorkout
            
            let saveDuration = existingWorkout.duration
            return (id, saveDuration)
        }
        
        let newWorkout = workoutRepo.create()
        newWorkout.id = UUID()
        newWorkout.date = Date()
        
        self.currentWorkout = newWorkout
        
        return (newWorkout.id?.uuidString ?? "" , 0)
    }
    
    func cancelWorkoutSession() {
        
    }
    
    func finishWorkout(duration: Double) {
        
    }
    
    func addExercise(exerciseID: String) {
        
    }
    
    func deleteExercise(workoutExerciseID: String) {
        
    }
    
    func replaceExercise(workoutExerciseID: String, with newExerciseID: String) {
        
    }
    
    func updateExerciseNote(workoutExerciseID: String, note: String) {
        
    }
    
    func addNewSet(to workoutExerciseID: String) {
        
    }
    
    func updateSet(setID: String, weight: Double, reps: Int, isDone: Bool) {
        
    }
    
    func deleteSet(setID: String) {
        
    }
}
