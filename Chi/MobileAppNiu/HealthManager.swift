//
//  HealthManager.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 19/9/2024.
//
import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()

    init() {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let daylight = HKQuantityType.quantityType(forIdentifier: .timeInDaylight)!
        let noise = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure)!
        let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        let healthTypes: Set = [steps, daylight, noise, hrv]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("Error fetching health data")
            }
        }
    }
    func fetchTodaySteps() {
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching today's step data")
                return
            }
            let stepCount = quantity.doubleValue(for: HKUnit.count())
            print("Today's steps: \(stepCount)")
        }
        healthStore.execute(query)
    }
    
    func fetchTodayDaylight() {
        guard let daylight = HKQuantityType.quantityType(forIdentifier: .timeInDaylight) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: daylight, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            guard let quantity = result?.averageQuantity(), error == nil else {
                print("Error fetching today's daylight data")
                return
            }
            let daylightHours = quantity.doubleValue(for: HKUnit.hour())
            print("Today's daylight hours: \(daylightHours)")
        }
        healthStore.execute(query)
    }
    
    func fetchTodayNoiseLevels() {
        guard let noise = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: noise, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            guard let quantity = result?.averageQuantity(), error == nil else {
                print("Error fetching today's noise level data")
                return
            }
            let averageNoise = quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            
            print("Today's average noise level: \(averageNoise) dB")
        }
        healthStore.execute(query)
    }
    
    func fetchTodayHRV() {
        guard let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: hrv, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            guard let quantity = result?.averageQuantity(), error == nil else {
                print("Error fetching today's HRV data")
                return
            }
            let hrvValue = quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            print("Today's HRV: \(hrvValue) ms")
        }
        healthStore.execute(query)
    }
    func fetchTimeIntervalByActivity(timePeriod: TimePeriod,  activity: HKQuantityTypeIdentifier,completion: @escaping ([LineChartData]) -> Void) {
        guard let activity = HKQuantityType.quantityType(forIdentifier: activity) else { return }
        
        let calendar = Calendar.current
        let endDate = Date()
        var startDate: Date
        var labels: [String] = []
        
        switch timePeriod {
        case .day:
            startDate = calendar.startOfDay(for: endDate)
            labels = (0..<24).map { "\($0)" } // Hour labels
            fetchHourly(startDate: startDate, endDate: endDate, labels: labels, activityType: activity) { hourlyData in
                completion(hourlyData) // Return hourly data
            }
            
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
            labels = calendar.shortWeekdaySymbols // Day labels
            fetchDaily(startDate: startDate, endDate: endDate, labels: labels, activityType: activity) { dailyData in
                completion(dailyData) // Return daily data
            }

        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
            let daysInMonth = calendar.range(of: .day, in: .month, for: endDate)!.count
            labels = (1...daysInMonth).map { "\($0)" } // Day numbers
            fetchDaily(startDate: startDate, endDate: endDate, labels: labels, activityType: activity) { dailyData in
                completion(dailyData) // Return daily data
            }

        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: endDate)!
            let months = (0..<6).map { calendar.date(byAdding: .month, value: -$0, to: endDate)! }
            labels = months.compactMap { calendar.shortMonthSymbols[calendar.component(.month, from: $0) - 1] } // Use abbreviated month labels
            fetchMonthly(startDate: startDate, endDate: endDate, labels: labels, activityType: activity) { monthlyData in
                completion(monthlyData) // Return monthly data
            }

        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
            let months = (0..<12).map { calendar.date(byAdding: .month, value: -$0, to: endDate)! }
            labels = months.compactMap { calendar.shortMonthSymbols[calendar.component(.month, from: $0) - 1] } // Use abbreviated month labels
            fetchMonthly(startDate: startDate, endDate: endDate, labels: labels, activityType: activity) { monthlyData in
                completion(monthlyData) // Return monthly data
            }
        }
    }
    private func fetchHourly(startDate: Date, endDate: Date, labels: [String], activityType: HKQuantityType, completion: @escaping ([LineChartData]) -> Void) {
        var hourlySteps: [Double] = Array(repeating: 0.0, count: 24)
        let group = DispatchGroup() // To wait for all queries to complete

        for hour in 0..<24 {
            guard let hourStart = Calendar.current.date(bySetting: .hour, value: hour, of: startDate),
                  let hourEnd = Calendar.current.date(bySetting: .hour, value: hour + 1, of: startDate) else {
                continue
            }
            let predicate = HKQuery.predicateForSamples(withStart: hourStart, end: hourEnd, options: .strictStartDate)
            
            let options: HKStatisticsOptions = (activityType.identifier == HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue) ? .discreteAverage : .cumulativeSum

            let query = HKStatisticsQuery(quantityType: activityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                
                var count = 0.0
                if activityType.identifier == HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue {
                    count = result?.averageQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) ?? 0.0
                }
                else{
                    count = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0.0
                }
                hourlySteps[hour] = count
                
                // Notify the group when a query finishes
                group.leave()
            }
            healthStore.execute(query)
            group.enter() // Indicate that a query is starting
        }
        
        // After all queries have completed, create the LineChartData and call completion
        group.notify(queue: .main) {
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: hourlySteps[$0]) }
            print("Hourly activity: \(lineChartData)")
            completion(lineChartData)
        }
    }

    private func fetchDaily(startDate: Date, endDate: Date, labels: [String], activityType: HKQuantityType, completion: @escaping ([LineChartData]) -> Void) {
        var dailySteps: [Double] = Array(repeating: 0.0, count: labels.count)
        let numberOfDays = labels.count
        let calendar = Calendar.current
        let group = DispatchGroup() // To wait for all queries to complete

        for day in 0..<numberOfDays {
            let dayStart = calendar.date(byAdding: .day, value: -day, to: endDate)!
            let dayEnd = calendar.date(byAdding: .day, value: -day + 1, to: endDate)!
            
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            
            let options: HKStatisticsOptions = (activityType.identifier == HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue) ? .discreteAverage : .cumulativeSum
            
            let query = HKStatisticsQuery(quantityType: activityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                
                var count = 0.0
                if activityType.identifier == HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue {
                    count = result?.averageQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) ?? 0.0
                }
                else{
                    count = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0.0
                }
                dailySteps[day] = count
                
                // Notify the group when a query finishes
                group.leave()
            }
            
            healthStore.execute(query)
            group.enter() // Indicate that a query is starting
        }
        
        // After all queries have completed, create the LineChartData and call completion
        group.notify(queue: .main) {
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: dailySteps[$0]) }
            print("Daily activity: \(lineChartData)")
            completion(lineChartData)
        }
    }


    private func fetchMonthly(startDate: Date, endDate: Date, labels: [String], activityType: HKQuantityType, completion: @escaping ([LineChartData]) -> Void) {
        var monthlySteps: [Double] = Array(repeating: 0.0, count: labels.count)
        let numberOfMonths = labels.count
        let calendar = Calendar.current
        let group = DispatchGroup() // To wait for all queries to complete

        for month in 0..<numberOfMonths {
            let monthStart = calendar.date(byAdding: .month, value: -month, to: endDate)!
            let monthEnd = calendar.date(byAdding: .month, value: -month + 1, to: endDate)!
            
            let predicate = HKQuery.predicateForSamples(withStart: monthStart, end: monthEnd, options: .strictStartDate)
            
            let options: HKStatisticsOptions = (activityType.identifier == HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue) ? .discreteAverage : .cumulativeSum
            
            let query = HKStatisticsQuery(quantityType: activityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                var count = 0.0
                if activityType.identifier == HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue {
                    count = result?.averageQuantity()?.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel()) ?? 0.0
                }
                else{
                    count = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0.0
                }
                monthlySteps[month] = count
                
                // Notify the group when a query finishes
                group.leave()
            }
            
            healthStore.execute(query)
            group.enter() // Indicate that a query is starting
        }
        
        // After all queries have completed, create the LineChartData and call completion
        group.notify(queue: .main) {
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: monthlySteps[$0]) }
            print("Monthly activity: \(lineChartData)")
            completion(lineChartData)
        }
    }


}
