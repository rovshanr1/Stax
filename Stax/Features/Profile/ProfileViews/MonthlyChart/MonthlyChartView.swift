//
//  MonthlyChartView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 18.04.26.
//

import SwiftUI
import Charts

struct MonthlyChartView: View {
    @State private var selectedMetric: MonthlyChartMetric = .volume
    @State private var selectedRange: ChartTimeRange = .week
    
    var data: [MonthlyChartData]
    
    private var calculator: MonthlyChartCalculator { .init(data: data) }
    private var filteredData: [MonthlyChartData] { calculator.filteredData(for: selectedRange) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(calculator.headerText(for: selectedMetric, range: selectedRange))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(selectedRange.displayText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Picker("", selection: $selectedRange) {
                    ForEach(ChartTimeRange.allCases, id: \.self){ range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 70, alignment: .trailing)
                .fixedSize()
            }
            .padding(.bottom, 4)
            
            
            if data.isEmpty{
                
                VStack(spacing: 8){
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    
                    Text("No workout data yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(.secondary.opacity(0.05))
                .cornerRadius(8)
                
            }else{
                chartView
            }
          
            
        }
        .animation(.easeInOut, value: selectedMetric)
        .animation(.easeInOut, value: selectedRange)
    }
    
    
    //MARK: - Chart View
    @ViewBuilder
    fileprivate var chartView: some View{
        Chart(data) {item in
            BarMark(
                x:.value("Date", item.date, unit: .day),
                y: .value("Value", calculator.value(for: item, metric: selectedMetric))
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
}

