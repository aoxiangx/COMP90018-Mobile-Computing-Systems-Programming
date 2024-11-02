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
    
    
    @EnvironmentObject var locationManager: LocationManager
    

    var body: some View {
        Chart {
            ForEach(chartData, id: \.id) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Constants.gray3)
                
                if !hideDetail {
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Value", item.value)
                    )
                    .symbol(Circle().strokeBorder()) // Show points when hideDetail is false
                }
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
        if(activity == Activity.green){
            let greenSpaceManager = GreenSpaceManager()
            let (labels, greenSpaceTimes) = greenSpaceManager.fetchGreenSpaceTimes(for: timePeriod)
//            print("date: \(labels), value: \(greenSpaceTimes)")
            self.chartData = greenSpaceTimes.enumerated().map { index, value in
                
                LineChartData(id: UUID(), date: labels[index], value: value)
            }
            
           
        }
        else{
            manager.fetchTimeIntervalByActivity(timePeriod: timePeriod, activity: activity) { data in
                self.chartData = data
//                print("chartData: \(self.chartData)")
            }
        }
    }
    
    // Format the labels depending on the time period
    private func shouldShowLabel(for date: String) -> Bool {
        let components = date.split(separator: "/") // Split the date into components

        guard let dayString = components.last.map(String.init) else {
            return false // Return false if there is no last component
        }

        switch timePeriod {
        case .day:
            return isImportantHour(date: dayString) // Check if it's an important hour
        case .month:
            // Only show day labels, not month
            return isImportantDay(date: dayString) // Check if it's an important day
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
        let importantDays = ["1", "5", "10", "15", "20", "25", "30"] // Add days as needed
        return importantDays.contains(date) // Return true if the given date is an important day
    }

}

#Preview {

    ChartView(timePeriod: .day,hideDetail: false,activity:.noise).environmentObject(HealthManager())
}
