//
//  ExerciseDomainModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation

nonisolated struct ExerciseDomainModel: Hashable, Codable, Sendable{
    let id: String
    let name: String
    let targetMuscleGroups: MuscleGroup?
    let videoURL: String?
    let exerciseImage: String?
}
