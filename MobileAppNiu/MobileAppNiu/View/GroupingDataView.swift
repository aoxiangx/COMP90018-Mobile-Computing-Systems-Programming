//
//  GroupingDataView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI
import Charts

struct GroupingDataView: View {
    @State private var selectedTimePeriod: TimePeriod = .day
    let data: [LineChartData] = [
        LineChartData(date: "09/01", value: 75.0),
        LineChartData(date: "09/02", value: 82.5),
        LineChartData(date: "09/03", value: 91.0),
        LineChartData(date: "09/04", value: 68.4),
        LineChartData(date: "09/05", value: 80.2),
        LineChartData(date: "09/06", value: 80.2),
        LineChartData(date: "09/07", value: 75.0),
        ]
    var body: some View {
        VStack {
            // Time Period Picker
            CustomNavigationBar(
                title: "Daylight Time",
                iconName: "sun.max.fill",
                onBackButtonTap: {
                    print("Back button tapped")
                }
            )
            Picker("Select Time Period", selection: $selectedTimePeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                        .font(Font.custom("Roboto", size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                        .frame(width: 18, alignment: .top)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .frame(height: 22)

            // Content aligned to the left
            VStack(alignment: .leading) {
                Text("24 Min")
                    .font(.system(size: 32))
                    .frame(height: 42)
                Text("Past 7 Days")
                    .font(.system(size: 12))
            }
            .padding(.leading)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            
            ChartView(data:data)
            SuggestionsCapsules()
                .padding(8)
            ExplainationView()
                .padding(8)
            
        }
    }
}
private func getData(for period: TimePeriod) -> [CGFloat] {
    switch period {
    case .day:
        return [0.2, 0.5, 0.3, 0.7, 0.4, 0.6, 0.8]
    case .week:
        return [0.3, 0.6, 0.4, 0.7, 0.5, 0.9, 0.6]
    case .month:
        return [0.4, 0.5, 0.7, 0.8, 0.6, 0.9, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7]
    case .sixMonths:
        return [0.5, 0.6, 0.8, 0.7, 0.9, 0.8, 0.7, 0.6, 0.5, 0.7, 0.8, 0.9, 0.6, 0.7, 0.8, 0.9]
    case .year:
        return [0.6, 0.7, 0.8, 0.6, 0.5, 0.7, 0.8, 0.9, 0.7, 0.6, 0.8, 0.9]
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
        return ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    case .year:
        return ["Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7", "Q8", "Q9", "Q10", "Q11", "Q12"]
    }
}

private func getYLabels() -> [String] {
    return ["0", "0.2", "0.4", "0.6", "0.8", "1"]
}

enum TimePeriod: String, CaseIterable {
    case day = "D"
    case week = "W"
    case month = "M"
    case sixMonths = "6M"
    case year = "Y"
}
struct GroupingDataView_Previews: PreviewProvider {
    static var previews: some View {
        GroupingDataView()
    }
}
