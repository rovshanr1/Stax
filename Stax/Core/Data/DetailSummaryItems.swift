//
//  DetailSummaryItems.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.03.26.
//

import Foundation

nonisolated struct DetailSummaryItems: Hashable, Sendable {
    let id = UUID()
    let workoutName: String
    let durationString: String
    let volumeString: String
    let setsLabel: String
    let caloriesBurnedString: String
}

nonisolated struct DetailExerciseHeaderItem: Hashable, Sendable {
    let id = UUID()
    let exerciseName: String
    let muscleGroups: [String]?
    let imageURL: String?
}

nonisolated struct DetailSetRowItem: Hashable, Sendable{
    let id = UUID()
    let setIndex: Int
    let weightString: String
    let repsString: String
    let isCompleted: Bool
}



