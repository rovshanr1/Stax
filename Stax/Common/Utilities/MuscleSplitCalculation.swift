//
//  MuscleSplitCalculation.swift
//  Stax
//
//  Created by Rovshan Rasulov on 29.03.26.
//

import Foundation

struct MuscleSplitCalculation {
    
    static func calculateMuscleSplit(from workout: WorkoutDomainModel) -> [MuscleData] {
        var muscleSetCounts: [MuscleGroup: Int] = [:]
        var totalValidSets = 0
        
        for workoutExercise in workout.workoutExercises {
            let muscleName = workoutExercise.exercise?.targetMuscleGroups ?? .other
            
            let setCount = workoutExercise.workoutSets.filter {$0.isCompleted}.count
            
            muscleSetCounts[muscleName, default: 0] += setCount
            totalValidSets += setCount
        }
        
        guard totalValidSets > 0 else {return [] }
        
        let chartDataArray = muscleSetCounts.map {(muscle, count) -> MuscleData in
            let percentage = (Double(count) / Double(totalValidSets)) * 100.0
            return MuscleData(muscleName: muscle.rawValue, percentage: percentage)
        }
        
        return chartDataArray.sorted { $0.percentage > $1.percentage }
    }
    
}
