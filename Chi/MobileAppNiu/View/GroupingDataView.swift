//
//  GroupingDataView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI
import Charts
import HealthKit
struct LineChartData {
    var id = UUID()
    var date: String
    var value: Double
}

struct GroupingDataView: View {
    var activity: Activity
    var icon:ImageResource
    @State private var selectedTimePeriod: TimePeriod = .day
    @EnvironmentObject var manager : HealthManager
//    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
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

            VStack(alignment: .leading) {
               Text(dynamicValue(for: selectedTimePeriod))
                   .font(.system(size: 32))
                   .frame(height: 42)
               Text(dynamicTimePeriodDescription(for: selectedTimePeriod))
                   .font(.system(size: 12))
           }
           .padding(.leading)
           .padding(.vertical, 16)
           .frame(maxWidth: .infinity, alignment: .leading)

            
            ChartView(timePeriod: selectedTimePeriod, hideDetail: false,activity: activity).environmentObject(manager)
            SuggestionsCapsules()
                .padding(8)
            ExplainationView()
                .padding(8)
            
        }
        .navigationBarTitleDisplayMode(.inline) // Set title display mode
        .navigationTitle("") // To avoid double title
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image(icon)
                        .foregroundColor(.yellow)
                    Text(activity.title) // Dynamic title based on activity
                        .font(Font.custom("Roboto", size: 16))
                        .foregroundColor(Constants.gray3)
                }
            }
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
enum Activity {
    case steps
    case daylight
    case noise
    case hrv

    var quantityTypeIdentifier: HKQuantityTypeIdentifier {
        switch self {
        case .steps:
            return .stepCount
        case .daylight:
            return .timeInDaylight
        case .noise:
            return .environmentalAudioExposure
        case .hrv:
            return .heartRateVariabilitySDNN
        }
    }
    var title: String {
        switch self {
        case .steps:
            return "Active Index"
        case .daylight:
            return "Daylight Time"
        case .noise:
            return "Noise Level"
        case .hrv:
            return "Stree Level"
        }
    }
}
private func dynamicValue(for period: TimePeriod) -> String {
        switch period {
        case .day:
            return "24 Min" // Placeholder for actual data
        case .week:
            return "3 Hours" // Placeholder for actual data
        case .month:
            return "12 Hours" // Placeholder for actual data
        case .sixMonths:
            return "180 Hours" // Placeholder for actual data
        case .year:
            return "1,200 Hours" // Placeholder for actual data
        }
    }
private func dynamicTimePeriodDescription(for period: TimePeriod) -> String {
       switch period {
       case .day:
           return "Past 24 Hours"
       case .week:
           return "Past 7 Days"
       case .month:
           return "Past Month"
       case .sixMonths:
           return "Past 6 Months"
       case .year:
           return "Past Year"
       }
   }
struct GroupingDataView_Previews: PreviewProvider {
    static var previews: some View {
        GroupingDataView(activity:.steps,icon: .activeIndexIcon).environmentObject(HealthManager())
    }
}
