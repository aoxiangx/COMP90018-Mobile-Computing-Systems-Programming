//
//  ChartView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI
import Charts
struct LineChartData {
    var id = UUID()
    var date: String
    var value: Double
}

struct ChartView: View {
    let data:[LineChartData]
    var body: some View {
        Chart {
            ForEach(data, id: \.id) { item in
                LineMark(
                    x: .value("Day", item.date),
                    y: .value("Value", item.value)
                )
                .interpolationMethod(.catmullRom) // Smoothing the line
                .symbol(Circle().strokeBorder())
                .foregroundStyle(Color.yellow.opacity(0.3))
                
            }
        }.frame(width: 361,
            height: 195)
        .chartXAxis(.hidden)
    }
}
let data: [LineChartData] = [
    LineChartData(date: "09/01", value: 75.0),
    LineChartData(date: "09/02", value: 82.5),
    LineChartData(date: "09/03", value: 91.0),
    LineChartData(date: "09/04", value: 68.4),
    LineChartData(date: "09/05", value: 80.2),
    LineChartData(date: "09/06", value: 80.2),
    LineChartData(date: "09/07", value: 75.0),
    ]

#Preview {
    ChartView(data: data)
}
