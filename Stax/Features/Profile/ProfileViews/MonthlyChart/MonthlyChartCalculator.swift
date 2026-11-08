//
//  MonthlyChartCalculator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 22.07.26.
//

import Foundation

struct MonthlyChartCalculator{
    var data: [MonthlyChartData]
    
    func filteredData(for range: ChartTimeRange) -> [MonthlyChartData] {
        guard let startDate = range.startDate() else { return data }
        return data.filter { $0.date >= startDate }
    }
    
    func value(for item: MonthlyChartData, metric: MonthlyChartMetric) -> Double {
        switch metric {
        case .volume: return item.volume
        case .duration: return item.duration
        case .sets: return item.sets
        }
    }
    
    func headerText(for metric: MonthlyChartMetric, range: ChartTimeRange) -> String {
        let total = filteredData(for: range).reduce(0.0) { $0 + value(for: $1, metric: metric) }
        switch metric {
        case .volume: return total.formatWeight()
        case .duration: return total.formatDurationFromProfile()
        case .sets: return "\(Int(total)) sets"
        }
    }
}
