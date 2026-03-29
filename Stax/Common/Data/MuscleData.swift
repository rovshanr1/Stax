//
//  MuscleData.swift
//  Stax
//
//  Created by Rovshan Rasulov on 29.03.26.
//

import Foundation


nonisolated struct MuscleData: Hashable, Sendable{
    let muscleName: String
    let percentage: Double
}

nonisolated struct MuscleSplitItem: Hashable, Sendable{
    let id = UUID()
    let muscleData: [MuscleData]
}
