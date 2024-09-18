//
//  ChartView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    var timePeriod: TimePeriod
    var hideDetail:Bool
    var body: some View {
        Chart {
            ForEach(getGraph(for: timePeriod), id: \.id) { item in
                LineMark(
                    x: .value("Day", item.date),
                    y: .value("Value", item.value)
                )
            }
        }.frame(height: 195)
        .chartXAxis(hideDetail ? .hidden : .visible) // Hide X-axis
        .chartYAxis(hideDetail ? .hidden : .visible) // Hide Y-axis
        .chartLegend(hideDetail ? .hidden : .visible) // Hide the legend if needed
    }
}

private func getData(for period: TimePeriod) -> [Double] {
    switch period {
    case .day:
        return [0.2, 0.5, 0.3, 0.7, 0.4, 0.6, 0.8]
    case .week:
        return [0.3, 0.6, 0.4, 0.7, 0.5, 0.9, 0.6]
    case .month:
        return [0.4, 0.5, 0.7, 0.8, 0.6, 0.9, 0.7]
    case .sixMonths:
        return [0.5, 0.6, 0.8, 0.7, 0.9, 0.8]
    case .year:
        return [0.6, 0.7, 0.8, 0.6]
    }
}

private func getXLabels(for period: TimePeriod) -> [String] {
    switch period {
    case .day:
        return ["1", "2", "3", "4", "5", "6", "7"]
    case .week:
        return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    case .month:
        return ["1", "5", "10", "15", "20", "25", "30"]
    case .sixMonths:
        return ["Apr", "May", "Jun", "Jul", "Aug", "Sep"]
    case .year:
        return ["Q1", "Q2", "Q3", "Q4"]
    }
}
private func getGraph(for period: TimePeriod) -> [LineChartData] {
    let values = getData(for: period)      // Get the values
        let labels = getXLabels(for: period)   // Get the labels

        // Ensure both arrays have the same count to avoid mismatches
        guard values.count == labels.count else {
            print("Mismatch in number of values and labels")
            return []
        }

        // Combine them into [LineChartData]
        return zip(labels, values).map { LineChartData(date: $0, value: $1) }
}

#Preview {

    ChartView(timePeriod: .year,hideDetail: true)
}
