//
//  MuscleGroup.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.03.26.
//

import Foundation

enum MuscleGroup: String, CaseIterable, Hashable, Sendable, Codable{
    case chest = "Chest"
    case back = "Back"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case quads = "Quads"
    case biceps = "Biceps"
    case shoulders = "Shoulders"
    case triceps = "Triceps"
    case rearDelts = "Rear Delts"
    case calves = "Calves"
    case upperChest = "Upper Chest"
    case legs = "Legs"
    
    case other = "Other"
}
