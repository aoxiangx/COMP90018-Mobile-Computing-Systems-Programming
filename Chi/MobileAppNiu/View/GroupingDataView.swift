//
//  GroupingDataView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//
// GroupingDataView.swift

import SwiftUI
import Charts
import HealthKit

struct GroupingDataView: View {
    var activity: Activity
    var icon: ImageResource
    @State private var selectedTimePeriod: TimePeriod = .day
    @EnvironmentObject var manager: HealthManager
    @State private var dynamicValue: String = "Loading..."

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
            .onChange(of: selectedTimePeriod) { newPeriod in
                updateData(for: newPeriod)
            }

            VStack(alignment: .leading) {
                Text(dynamicValue)
                    .font(.system(size: 32))
                    .frame(height: 42)
                Text(dynamicTimePeriodDescription(for: selectedTimePeriod))
                    .font(.system(size: 12))
            }
            .padding(.leading)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            ChartView(timePeriod: selectedTimePeriod, hideDetail: false, activity: activity)
                .environmentObject(manager)
                .padding()

            SuggestionsCapsules()
                .padding(8)
            ExplainationView()
                .padding(8)
        }
        .navigationTitle("") // This avoids double titles
        .navigationBarTitleDisplayMode(.inline) // Set title display mode
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
        .onAppear {
            updateData(for: selectedTimePeriod)
        }
    }

    private func updateData(for period: TimePeriod) {
        manager.fetchAverage(endDate: Date(), activity: activity, period: period) { result in
            DispatchQueue.main.async {
                self.dynamicValue = "\(result) \(activity.unitDescription)"
            }
        }
    }
}

/// 动态文本描述基于上下文
private func dynamicTimePeriodDescription(for period: TimePeriod) -> String {
    switch period {
    case .day:
        return "Today"
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
        NavigationView {
            GroupingDataView(activity: .hrv, icon: .stress)
                .environmentObject(HealthManager())
        }
    }
}
