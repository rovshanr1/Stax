//
//  ExerciseType.swift
//  Stax
//
//  Created by Rovshan Rasulov on 14.08.26.
//

import Foundation

nonisolated enum ExerciseType: String, Codable, CaseIterable, Sendable {
    case weighted
    case bodyweight
    case timeBased
    
    var requiresWeight: Bool {
        self == .weighted
    }
}
