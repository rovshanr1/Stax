//
//  WorkoutShareService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 18.03.26.
//

import Foundation

protocol WorkoutShareServiceProtocol{
    func generateShareText(from workout: Workout) -> String
}

final class WorkoutTextShareService: WorkoutShareServiceProtocol{
    func generateShareText(from workout: Workout) -> String {
        var text = "Stax Workout: \(workout.name ?? "Unknown")\n"
        text += "🏋️ Volume: \(workout.volume) kg\n"
        text += "\nTracked with #StaxApp"
        return text
    }
}
