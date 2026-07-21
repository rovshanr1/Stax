//
//  ChartTimeRange.swift
//  Stax
//
//  Created by Rovshan Rasulov on 22.07.26.
//

import Foundation

enum ChartTimeRange: String, CaseIterable{
    case week = "Week"
    case month = "Month"
    case threeMonths = "3M"
    
    var displayText: String {
        switch self {
        case .week: return "This Week"
        case .month: return "This Month"
        case .threeMonths: return "Last 3 Months"
        }
    }
    
    var xAxisStrideDays: Int {
        switch self {
        case .week: return 1
        case .month: return 7
        case .threeMonths: return 14
        }
    }
    
    func startDate(from calendar: Calendar = .current) -> Date? {
        switch self {
        case .week: return calendar.date(byAdding: .day, value: -7, to: Date())
        case .month: return calendar.date(byAdding: .month, value: -1, to: Date())
        case .threeMonths: return calendar.date(byAdding: .month, value: -3, to: Date())
        }
    }
}
