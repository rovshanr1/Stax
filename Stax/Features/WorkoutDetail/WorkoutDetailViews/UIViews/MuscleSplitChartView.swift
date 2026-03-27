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
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Muscle Split")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Chart(chartData, id: \.muscleName){ item in
                BarMark(x: .value("", item.percentage),y: .value("", item.muscleName))
                    .foregroundStyle(.primary)
                    .annotation(position: .trailing, alignment: .center){
                        Text("\(Int(item.percentage))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.bold)
                    }
                
                
                
                
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel()
                }
            }
            .frame(height: CGFloat(max(1, chartData.count) * 40))
            .chartLegend(.hidden)
            .listRowSeparator(.hidden)
            
            
        }
    }
}

#Preview {
    MuscleSplitChartView(chartData: [MuscleData(muscleName: "Back", percentage: 10), MuscleData(muscleName: "Triceps", percentage: 20), MuscleData(muscleName: "Chest", percentage: 30)])
}
