//
//  WorkoutShareService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 18.03.26.
//

import Foundation

protocol WorkoutShareServiceProtocol{
    func generateShareText(from workout: WorkoutDomainModel) -> String
}

final class WorkoutTextShareService: WorkoutShareServiceProtocol{
    func generateShareText(from workout: WorkoutDomainModel) -> String {
        var text = "Stax Workout: \(workout.name)\n"
        text += "🏋️ Volume: \(workout.volume) kg\n"
        text += "\nTracked with #StaxApp"
        return text
    }
}
