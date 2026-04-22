//
//  WorkoutSetDomainModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation

nonisolated struct WorkoutSetDomainModel: Hashable, Codable, Sendable{
    let id: String
    let isCompleted: Bool
    let orderIndex: Int16
    let previous: String
    let reps: Int16
    let restTime: Double?
    let weight: Double
}
