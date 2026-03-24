//
//  WorkoutDomainModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation

struct WorkoutDomainModel: Hashable, Codable {
    let id: String
    let name: String
    let duration: Double
    let volume: Double
    let workoutDescription: String?
    let date: Date
    
    //relationships
    let workoutExercises: [WorkoutExerciseDomainModel]
}

