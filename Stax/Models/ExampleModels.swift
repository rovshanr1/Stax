//
//  ExampleModels.swift
//  Stax
//
//  Created by Rovshan Rasulov on 27.11.25.
//

import Foundation


struct ExampleModels: Codable{
    struct Workout: Codable, Identifiable {
        let id: UUID?
        let name: String
        let workoutExercises: [WorkoutExercise]? //to-many
    }
    
    struct WorkoutExercise: Codable, Identifiable {
        let id: UUID?
        let orderIndex: Int16
        let exercise: Exercise? //to-one
        let workout: Workout? //to-one
        let workoutSets: [WorkoutSet]? //to-many
    }

    struct WorkoutSet: Codable, Identifiable {
        let id: UUID?
        let reps: Int16
        let restTime: Double
        let wight: Double?
        let rir: Int16
        let workoutExercise: WorkoutExercise? //to-one
        
    }
   
    struct Exercise: Codable, Identifiable {
        let id: UUID?
        let name: String
        let videoURL: String?
        let workoutExercises: [WorkoutExercise]? //inverse to-many
    }
}


