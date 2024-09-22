//
//  ChartView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 19/9/2024.
//

import SwiftUI
import Charts
import HealthKit

struct ChartView: View {
    var timePeriod: TimePeriod
    var hideDetail: Bool
    var activity: Activity
    @EnvironmentObject var manager: HealthManager
    @State private var chartData: [LineChartData] = []
    

    var body: some View {
        Chart {
            ForEach(chartData, id: \.id) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .interpolationMethod(.catmullRom)
                .symbol(Circle().strokeBorder())
                .foregroundStyle(Constants.gray3)
            }
        }
        .frame(height: 195)
        .chartXAxis {
            if hideDetail {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine() // Only show gridlines, no labels
                }
            } else {
                AxisMarks(values: .automatic) { value in
                    if shouldShowLabel(for: value.as(String.self) ?? "") {
                        AxisValueLabel() // Show label for important hours or days
                    } else {
                        AxisGridLine() // Still show gridline for non-important values
                    }
                }
            }
        }
        .chartYAxis(hideDetail ? .hidden : .visible) // Hide Y-axis
        .chartLegend(hideDetail ? .hidden : .visible) // Hide the legend if needed
        .onAppear {
            fetchChartData()
        }
        .onChange(of: timePeriod) {
                    fetchChartData() // Fetch chart data when timePeriod changes
        }
    }

    private func fetchChartData() {
        manager.fetchTimeIntervalByActivity(timePeriod: timePeriod,activity: activity.quantityTypeIdentifier) { data in
            self.chartData = data
        }
    }
    
    // Format the labels depending on the time period
    private func shouldShowLabel(for date: String) -> Bool {
            switch timePeriod {
            case .day:
                return isImportantHour(date: date)
            case .month:
                return isImportantDay(date: date)
            default:
                return true // Show all labels for other time periods
            }
        }

    // Helper function to determine if the hour is important (12 AM, 6 AM, 12 PM, 6 PM)
    private func isImportantHour(date: String) -> Bool {
        let importantHours = ["0", "6", "12", "23"]
        return importantHours.contains(date)
    }

    // Helper function to determine if the day is important (1, 5, 10, 15, 20, 25, 30)
    private func isImportantDay(date: String) -> Bool {
        let importantDays = ["1", "8", "15", "22", "29"]
        // Return true if the given date is an important day
        return importantDays.contains(date)
    }

}

#Preview {

    ChartView(timePeriod: .day,hideDetail: false,activity:.steps).environmentObject(HealthManager())
}
