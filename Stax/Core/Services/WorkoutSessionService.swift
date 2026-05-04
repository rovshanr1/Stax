//
//  WorkoutSessionService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.05.26.
//

import Foundation
import Combine

protocol SessionServiceProtocol{
    func setupSession(workoutID: String?) -> String
    func cancelWorkoutSession(sessionID: String)
    func finishWorkout(sessionID: String, duration: Double)
    
    func addExercise(exerciseID: String, to sessionID: String)
    func deleteExercise(workoutExerciseID: String)
    func replaceExercise(workoutExerciseID: String, with newExerciseID: String)
    func updateExerciseNote(workoutExerciseID: String, note: String)
    
    func addNewSet(to workoutExerciseID: String)
    func updateSet(setID: String, weight: Double, reps: Int, isDone: Bool)
    func deleteSet(setID: String)
}

final class WorkoutSessionService: SessionServiceProtocol{
    func setupSession(workoutID: String?) -> String {
        
    }
    
    func cancelWorkoutSession(sessionID: String) {
        
    }
    
    func finishWorkout(sessionID: String, duration: Double) {
        
    }
    
    func addExercise(exerciseID: String, to sessionID: String) {
        
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
