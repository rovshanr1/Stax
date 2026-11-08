//
//  WorkoutCalorieCalculator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 14.08.26.
//

import Foundation

enum WorkoutCalorieCalculator{
    private static let averageCaloriesPerMinute: Double = 6.0
    
    static func estimateCalories(forDuration duration: TimeInterval) -> Double {
        (duration / 60.0) * averageCaloriesPerMinute
    }
}
