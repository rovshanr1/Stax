//
//  MonthlyChart.swift
//  Stax
//
//  Created by Rovshan Rasulov on 18.04.26.
//

import SwiftUI
import Charts

enum MonthlyChartMetric: String, CaseIterable{
    case volume = "Volume"
    case workout = "Workout"
    case duration = "Duration"
}


struct MonthlyChart: View {
    @State private var selectedMetric: MonthlyChartMetric = .volume
    
    var data: [MonthlyChartData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(headerText(for: selectedMetric))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Thiw Week")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 4)
            
            Chart(data) {item in
                BarMark(
                    x:.value("Date", item.date, unit: .day),
                    y: .value("Value", getValue(for: item, metric: selectedMetric))
                )
                .foregroundStyle(Color.accentColor.gradient)
                .cornerRadius(4)
            }
            .frame(height: 120)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)){ value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            
            
            Picker(selection: $selectedMetric, label: Text("")) {
                ForEach(MonthlyChartMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 16)
        .animation(.easeInOut, value: selectedMetric)
    }
    
    private func getValue(for item: MonthlyChartData, metric: MonthlyChartMetric ) -> Double{
        switch metric{
        case .volume:
            return item.volume
        case .duration:
            return item.duration
        case .workout:
            return Double(item.workout)
        }
    }
    
    private func headerText(for metric: MonthlyChartMetric) -> String{
        let total = data.reduce(0.0) {$0 + getValue(for: $1, metric: metric) }
        
        switch metric{
        case .volume:
            return total.formatWeight()
        case .duration:
            return total.formatDurationFromProfile()
        case .workout:
            return "\(Int(total)) workouts"
        }
    }
}

