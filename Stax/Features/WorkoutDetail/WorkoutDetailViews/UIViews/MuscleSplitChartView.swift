//
//  MuscleSplitChartView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 27.03.26.
//

import SwiftUI
import Charts

struct MuscleSplitChartView: View {
    let chartData: [MuscleData]
    
    private let rowHeight: CGFloat = 56
    private let barHeight: CGFloat = 20
    
    private var xDomain: ClosedRange<Double> {
        let maxValue = chartData.map(\.percentage).max() ?? 100
        return 0...max(maxValue * 1.2, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Muscle Split")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            Chart(chartData){ item in
                BarMark(
                    x: .value("", item.percentage),
                    y: .value("", item.muscleName),
                    height: .fixed(barHeight)
                )
                .foregroundStyle(.primary)
                .cornerRadius(5)
                .annotation(position: .top,
                            alignment: .leading,
                            spacing: 4,
                            overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                    Text(item.muscleName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                            .annotation(position: .trailing, alignment: .center, spacing: 6) {
                                Text("\(Int(item.percentage))%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)
                            }
                
            }
            .chartXScale(domain: xDomain)
            .chartYScale(range: .plotDimension(padding: 8))
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .frame(height: CGFloat(max(1, chartData.count)) * rowHeight)
     
            Divider()
                .background(Color(uiColor: .separator))
        }
    }
}


