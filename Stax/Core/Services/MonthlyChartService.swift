//
//  MonthlyChartService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 18.04.26.
//

import Foundation

protocol MonthlyChartServiceProtocol{
    func generateChartData(from workouts: [WorkoutDomainModel]) -> [MonthlyChartData]
}


final class MonthlyChartService: MonthlyChartServiceProtocol {
    func generateChartData(from workouts: [WorkoutDomainModel]) -> [MonthlyChartData] {
        let calendar = Calendar.current
        
        guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date()) else{
            return []
        }
        
        let recentWorkouts = workouts.filter { $0.date >= threeMonthsAgo }
        
        let groupedByDay = Dictionary(grouping: recentWorkouts) { workout in
            calendar.startOfDay(for: workout.date)
        }
        
        var chartDataArray: [MonthlyChartData] = []
        
        for (day, dailyWorkouts) in groupedByDay {
            let totalVolume = dailyWorkouts.reduce(0.0) {$0 + ($1.volume)}
            let totalDuration = dailyWorkouts.reduce(0.0) { $0 + ($1.duration)}
            let totalWorkouts = dailyWorkouts.reduce(0.0) { $0 + Double(($1.sets))}
            
            let chartData = MonthlyChartData(
                date: day,
                volume: totalVolume,
                duration: totalDuration,
                sets: totalWorkouts
            )
            
            chartDataArray.append(chartData)
        }
        return chartDataArray.sorted { $0.date < $1.date }
    }
}
