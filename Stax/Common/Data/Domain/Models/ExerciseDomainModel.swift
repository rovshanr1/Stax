//
//  ExerciseDomainModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation

struct ExerciseDomainModel: Hashable, Codable{
    let id: String
    let name: String
    let targetMuscleGroups: String?
    let videoURL: String?
}
