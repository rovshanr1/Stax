//
//  MonthlyChartData.swift
//  Stax
//
//  Created by Rovshan Rasulov on 18.04.26.
//

import Foundation

nonisolated struct MonthlyChartData: Identifiable, Sendable, Hashable{
    let id = UUID()
    let date: Date
    let volume: Double
    let duration: Double
    let sets: Double
}
