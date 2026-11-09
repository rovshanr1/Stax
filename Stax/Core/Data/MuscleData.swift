//
//  MuscleData.swift
//  Stax
//
//  Created by Rovshan Rasulov on 29.03.26.
//

import Foundation


nonisolated struct MuscleData: Identifiable, Hashable, Sendable{
    var id: String { muscleName }
    let muscleName: String
    let percentage: Double
}

nonisolated struct MuscleSplitItem: Hashable, Sendable{
    let muscleData: [MuscleData]
}
