//
//  GroupingDataView.swift
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

struct GroupingDataView: View {
    @State private var selectedTimePeriod: TimePeriod = .day
    @EnvironmentObject var manager : HealthManager
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

            
            ChartView(timePeriod: selectedTimePeriod, hideDetail: false,activity: .stepCount).environmentObject(manager)
            SuggestionsCapsules()
                .padding(8)
            ExplainationView()
                .padding(8)
            
        }
    }
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
        GroupingDataView().environmentObject(HealthManager())
    }
}