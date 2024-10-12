//
//  HealthManager.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 19/9/2024.
//


import Foundation
import HealthKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()

    init() {
        // 使用可选绑定来安全地获取 HKQuantityType
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let daylight = HKQuantityType.quantityType(forIdentifier: .timeInDaylight),
              let noise = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure),
              let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("Error: Unable to get quantity types")
            return
        }
        
        let healthTypes: Set = [steps, daylight, noise, hrv]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("Error fetching health data: \(error.localizedDescription)")
            }
        }
    }
    
    /// 获取特定活动和时间段的平均值
    func fetchAverage(endDate: Date = Date(), activity: Activity, completion: @escaping (Int) -> Void) {
        guard let activityType = HKQuantityType.quantityType(forIdentifier: activity.quantityTypeIdentifier) else {
            print("Invalid activity type: \(activity.quantityTypeIdentifier)")
            completion(0)
            return
        }
        
        let numberOfDays = 7  // 获取过去7天的数据
        var dailyValues: [Double] = Array(repeating: 0.0, count: numberOfDays)
        let calendar = Calendar.current
        let group = DispatchGroup() // 等待所有查询完成
        let options = activity.statisticsOption

        for day in 0..<numberOfDays {
            // 计算每一天的日期范围
            guard let dayStart = calendar.date(byAdding: .day, value: -day, to: endDate),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                print("Error calculating date range for day \(day)")
                continue
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: activityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                
                defer { group.leave() } // 确保总是调用 leave
                
                var value = 0.0
                switch activity {
                case .steps, .daylight:
                    if let sumQuantity = result?.sumQuantity() {
                        value = sumQuantity.doubleValue(for: activity.unit)
                    }
                case .noise, .hrv:
                    if let avgQuantity = result?.averageQuantity() {
                        value = avgQuantity.doubleValue(for: activity.unit)
                    }
                }
                dailyValues[day] = value
                print("Data for day \(day): \(value)")
            }
            
            group.enter() // 通知有一个查询开始
            healthStore.execute(query)
        }
        
        // 所有查询完成后计算平均值
        group.notify(queue: .main) {
            let total = dailyValues.reduce(0, +)
            let average = total / Double(numberOfDays)
            
            print("7-day average: \(average)")
            completion(Int(average))
        }
    }
    
    /// 根据活动和时间段获取数据
    func fetchTimeIntervalByActivity(timePeriod: TimePeriod, activity: Activity, completion: @escaping ([LineChartData]) -> Void) {
        let activityType = activity.quantityTypeIdentifier
        guard let activityHKType = HKQuantityType.quantityType(forIdentifier: activityType) else { return }
        
        let calendar = Calendar.current
        let endDate = Date()
        var startDate: Date
        var labels: [String] = []
        
        switch timePeriod {
        case .day:
            startDate = calendar.startOfDay(for: endDate)
            labels = (0..<24).map { "\($0)" } // 小时标签
            fetchHourly(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityHKType) { hourlyData in
                completion(hourlyData) // 返回每小时数据
            }
            
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
            labels = calendar.shortWeekdaySymbols // 天标签
            fetchDaily(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityHKType) { dailyData in
                completion(dailyData) // 返回每日数据
            }

        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
            let daysInMonth = calendar.range(of: .day, in: .month, for: endDate)!.count
            labels = (1...daysInMonth).map { "\($0)" } // 天数标签
            fetchDaily(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityHKType) { dailyData in
                completion(dailyData) // 返回每日数据
            }

        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: endDate)!
            let months = (0..<6).map { calendar.date(byAdding: .month, value: -$0, to: endDate)! }
            labels = months.compactMap { calendar.shortMonthSymbols[calendar.component(.month, from: $0) - 1] } // 使用缩写月份标签
            fetchMonthly(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityHKType) { monthlyData in
                completion(monthlyData) // 返回每月数据
            }

        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
            let months = (0..<12).map { calendar.date(byAdding: .month, value: -$0, to: endDate)! }
            labels = months.compactMap { calendar.shortMonthSymbols[calendar.component(.month, from: $0) - 1] } // 使用缩写月份标签
            fetchMonthly(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityHKType) { monthlyData in
                completion(monthlyData) // 返回每月数据
            }
        }
    }

    /// 获取每小时的数据
    private func fetchHourly(startDate: Date, endDate: Date, labels: [String], activity: Activity, activityType: HKQuantityType, completion: @escaping ([LineChartData]) -> Void) {
        var hourlyValues: [Double] = Array(repeating: 0.0, count: 24)
        let group = DispatchGroup() // 等待所有查询完成

        for hour in 0..<24 {
            guard let hourStart = Calendar.current.date(bySetting: .hour, value: hour, of: startDate),
                  let hourEnd = Calendar.current.date(bySetting: .hour, value: hour + 1, of: startDate) else {
                print("Error calculating hour range for hour \(hour)")
                continue
            }
            let predicate = HKQuery.predicateForSamples(withStart: hourStart, end: hourEnd, options: .strictStartDate)
            
            let options = activity.statisticsOption

            let query = HKStatisticsQuery(quantityType: activityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                
                defer { group.leave() }
                
                var value = 0.0
                switch activity {
                case .steps, .daylight:
                    if let sumQuantity = result?.sumQuantity() {
                        value = sumQuantity.doubleValue(for: activity.unit)
                    }
                case .noise, .hrv:
                    if let avgQuantity = result?.averageQuantity() {
                        value = avgQuantity.doubleValue(for: activity.unit)
                    }
                }
                hourlyValues[hour] = value
                print("Data for hour \(hour): \(value)")
            }
            group.enter() // 通知有一个查询开始
            healthStore.execute(query)
        }
        
        // 所有查询完成后创建 LineChartData 并调用 completion
        group.notify(queue: .main) {
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: hourlyValues[$0]) }
            print("Hourly activity: \(lineChartData)")
            completion(lineChartData)
        }
    }
    
    /// 获取每日的数据
    private func fetchDaily(startDate: Date, endDate: Date, labels: [String], activity: Activity, activityType: HKQuantityType, completion: @escaping ([LineChartData]) -> Void) {
        var dailyValues: [Double] = Array(repeating: 0.0, count: labels.count)
        let numberOfDays = labels.count
        let calendar = Calendar.current
        let group = DispatchGroup() // 等待所有查询完成

        for day in 0..<numberOfDays {
            guard let dayStart = calendar.date(byAdding: .day, value: -day, to: endDate),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                print("Error calculating date range for day \(day)")
                continue
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            let options = activity.statisticsOption

            let query = HKStatisticsQuery(quantityType: activityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                
                defer { group.leave() }
                
                var value = 0.0
                switch activity {
                case .steps, .daylight:
                    if let sumQuantity = result?.sumQuantity() {
                        value = sumQuantity.doubleValue(for: activity.unit)
                    }
                case .noise, .hrv:
                    if let avgQuantity = result?.averageQuantity() {
                        value = avgQuantity.doubleValue(for: activity.unit)
                    }
                }
                dailyValues[day] = value
                print("Data for day \(day): \(value)")
            }
            
            group.enter()
            healthStore.execute(query)
        }
        
        // 所有查询完成后创建 LineChartData 并调用 completion
        group.notify(queue: .main) {
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: dailyValues[$0]) }
            print("Daily activity: \(lineChartData)")
            completion(lineChartData)
        }
    }

    /// 获取每月的数据
    private func fetchMonthly(startDate: Date, endDate: Date, labels: [String], activity: Activity, activityType: HKQuantityType, completion: @escaping ([LineChartData]) -> Void) {
        var monthlyValues: [Double] = Array(repeating: 0.0, count: labels.count)
        let numberOfMonths = labels.count
        let calendar = Calendar.current
        let group = DispatchGroup() // 等待所有查询完成

        for month in 0..<numberOfMonths {
            guard let monthStart = calendar.date(byAdding: .month, value: -month, to: endDate),
                  let monthEnd = calendar.date(byAdding: .month, value: -month + 1, to: endDate) else {
                print("Error calculating date range for month \(month)")
                continue
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: monthStart, end: monthEnd, options: .strictStartDate)
            let options = activity.statisticsOption

            let query = HKStatisticsQuery(quantityType: activityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                var value = 0.0
                switch activity {
                case .steps, .daylight:
                    if let sumQuantity = result?.sumQuantity() {
                        value = sumQuantity.doubleValue(for: activity.unit)
                    }
                case .noise, .hrv:
                    if let avgQuantity = result?.averageQuantity() {
                        value = avgQuantity.doubleValue(for: activity.unit)
                    }
                }
                monthlyValues[month] = value
                
                // 通知组查询完成
                group.leave()
            }
            
            group.enter()
            healthStore.execute(query)
        }
        
        // 所有查询完成后创建 LineChartData 并调用 completion
        group.notify(queue: .main) {
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: monthlyValues[$0]) }
            print("Monthly activity: \(lineChartData)")
            completion(lineChartData)
        }
    }
    
    /// 获取今天的步数
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
    
    /// 获取今天的日光时间
    func fetchTodayDaylight() {
        guard let daylight = HKQuantityType.quantityType(forIdentifier: .timeInDaylight) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: daylight, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching today's daylight data")
                return
            }
            let daylightMinutes = quantity.doubleValue(for: HKUnit.minute())
            print("Today's daylight minutes: \(daylightMinutes)")
        }
        healthStore.execute(query)
    }
    
    /// 获取今天的噪音水平
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
    
    /// 获取今天的 HRV
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
}
