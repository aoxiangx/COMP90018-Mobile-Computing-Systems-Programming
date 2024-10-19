//
//  HealthManager.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 19/9/2024.
//


import Foundation
import HealthKit


struct SuggestionData: Identifiable {
    let id = UUID()
    var text: String
    var importance: Double  // 可以根据重要性排序或高亮显示
}



class HealthManager: ObservableObject {
    @Published var healthSuggestions: [SuggestionData] = []
    let healthStore = HKHealthStore()
    
    init() {
        // 使用可选绑定来安全地获取 HKQuantityType
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let daylight = HKQuantityType.quantityType(forIdentifier: .timeInDaylight),
              let noise = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure),
              let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
              let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Error: Unable to get types")
            return
        }
        
        let healthTypes: Set = [steps, daylight, noise, hrv, sleep]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("Error fetching health data: \(error.localizedDescription)")
            }
        }
    }
    func fetchTodaySteps(completion: @escaping (Double?, Error?) -> Void) {
        guard let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "HealthKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create step count type"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let quantity = result?.sumQuantity() else {
                completion(0.0, nil) // No steps found, returning 0
                return
            }
            
            let stepCount = quantity.doubleValue(for: HKUnit.count())
            completion(stepCount, nil)
        }
        
        healthStore.execute(query)
    }

    
    /// 获取今天的日光时间
    func fetchTodayDaylight(completion: @escaping (Double?, Error?) -> Void) {
        guard let daylight = HKQuantityType.quantityType(forIdentifier: .timeInDaylight) else {
            completion(nil, NSError(domain: "HealthKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create daylight type"]))
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: daylight, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let quantity = result?.sumQuantity() else {
                completion(0.0, nil) // No daylight found, returning 0
                return
            }
            
            let daylightMinutes = quantity.doubleValue(for: HKUnit.minute())
            completion(daylightMinutes, nil)
        }
        healthStore.execute(query)
    }

    /// 获取今天的噪音水平
    func fetchTodayNoiseLevels(completion: @escaping (Double?, Error?) -> Void) {
        guard let noise = HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure) else {
            completion(nil, NSError(domain: "HealthKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create noise level type"]))
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: noise, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let quantity = result?.averageQuantity() else {
                completion(0.0, nil) // No noise level data found, returning 0
                return
            }
            
            let averageNoise = quantity.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
            completion(averageNoise, nil)
        }
        healthStore.execute(query)
    }

    /// 获取今天的 HRV
    func fetchTodayHRV(completion: @escaping (Double?, Error?) -> Void) {
        guard let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(nil, NSError(domain: "HealthKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create HRV type"]))
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: hrv, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let quantity = result?.averageQuantity() else {
                completion(0.0, nil) // No HRV data found, returning 0
                return
            }
            
            let hrvValue = quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            completion(hrvValue, nil)
        }
        healthStore.execute(query)
    }

    /// 获取今天的睡眠数据
    func fetchTodaySleep(completion: @escaping (Double?, Error?) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Filter for 'asleep' sleep state
            let asleepSamples = results?.compactMap { sample -> HKCategorySample? in
                guard let categorySample = sample as? HKCategorySample else { return nil }
                return categorySample.value == HKCategoryValueSleepAnalysis.asleep.rawValue ? categorySample : nil
            }
            
            if let asleepSamples = asleepSamples, !asleepSamples.isEmpty {
                let totalAsleepTime = asleepSamples.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                let asleepHours = totalAsleepTime / 3600.0
                completion(asleepHours, nil)
            } else {
                completion(0.0, nil) // No sleep data found, returning 0
            }
        }
        
        healthStore.execute(query)
    }

    func updateHealthSuggestions() {
        
            
            var suggestions: [SuggestionData] = []
            
            let group = DispatchGroup()
            
            group.enter()
            fetchAverage(activity: .sleep, period: .day) { sleepAverage in
                if sleepAverage < 7.0 {
                    suggestions.append(SuggestionData(text: "You Need More Sleep", importance: 1.0))
                }
                group.leave()
            }
            
            group.enter()
            fetchAverage(activity: .daylight, period: .day) { daylightAverage in
                if daylightAverage < 60.0 {
                    suggestions.append(SuggestionData(text: "Spend More Time in Park", importance: 0.9))
                }
                group.leave()
            }
            
            group.enter()
            fetchAverage(activity: .steps, period: .day) { stepsAverage in
                if stepsAverage < 5000 {
                    suggestions.append(SuggestionData(text: "Stay Active", importance: 0.8))
                }
                group.leave()
            }
            
            // 等待所有数据获取完成
            group.notify(queue: .main) {
                // update health suggestion
                self.healthSuggestions = suggestions
            }
        }
    
    /// 获取特定活动和时间段的平均值
    func fetchAverage(endDate: Date = Date(), activity: Activity, period: TimePeriod, completion: @escaping (Double) -> Void) {
        let activityType = activity.activityType
        // Determine the number of days based on the selected period
        var numberOfDays: Int
        switch period {
        case .day:
            numberOfDays = 1
        case .week:
            numberOfDays = 7
        case .month:
            numberOfDays = 30
        case .sixMonths:
            numberOfDays = 180
        case .year:
            numberOfDays = 365
        }
        
        var dailyValues: [Double] = Array(repeating: 0.0, count: numberOfDays)
        let calendar = Calendar.current
        let group = DispatchGroup()
        let options = activity.statisticsOption
        
        for day in 0..<numberOfDays {
            // Calculate each day's date range
            guard let dayStart = calendar.date(byAdding: .day, value: -day, to: endDate),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                print("Error calculating date range for day \(day)")
                continue
            }
            if activity == Activity.sleep {
                let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
                let query = HKSampleQuery(sampleType: activityType as! HKSampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    
                    defer { group.leave() }
                    
                    guard error == nil else {
                        print("Error fetching sleep data: \(String(describing: error))")
                        return
                    }
                    
                    // Process sleep samples
                    var totalSleepTime = 0.0
                    if let samples = results as? [HKCategorySample] {
                        for sample in samples {
                            totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate) // Calculate sleep duration
                        }
                    }
                    
                    dailyValues[day] = totalSleepTime / 3600.0 // Convert seconds to hours
                    print("Data for day \(day): \(dailyValues[day]) hours of sleep")
                }
                group.enter()
                healthStore.execute(query)
            } else {
                // Use HKStatisticsQuery for other activities
                let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
                let query = HKStatisticsQuery(quantityType: activityType as! HKQuantityType, quantitySamplePredicate: predicate, options: activity.statisticsOption) { _, result, error in
                    
                    defer { group.leave() }
                    
                    var value = 0.0
                    switch activity {
                    case .steps, .daylight:
                        if let sumQuantity = result?.sumQuantity() {
                            value = sumQuantity.doubleValue(for: activity.unit!)
                        }
                    case .noise, .hrv:
                        if let avgQuantity = result?.averageQuantity() {
                            value = avgQuantity.doubleValue(for: activity.unit!)
                        }
                    case .sleep:
                        value = 0.0
                    }
                    dailyValues[day] = value
//                    print("Average Data for day \(day): \(value)")
                }
                group.enter()
                healthStore.execute(query)
            }
        }
        
        // Notify when all queries complete
        group.notify(queue: .main) {
            let total = dailyValues.reduce(0, +)
            let average = total / Double(numberOfDays)
            
            print("\(numberOfDays)-day average: \(average)")
       
            completion(Double(String(format: "%.1f", average)) ?? 0.0)
        }
    }
    
    /// 根据活动和时间段获取数据
    func fetchTimeIntervalByActivity(timePeriod: TimePeriod, activity: Activity, completion: @escaping ([LineChartData]) -> Void) {
        let activityType = activity.activityType
        let calendar = Calendar.current
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())! // Set to end of today
        var startDate: Date
        var labels: [String] = []

        switch timePeriod {
        case .day:
            // Calculate the start of the current day in local time
            startDate = calendar.startOfDay(for: endDate)
            labels = (0..<24).map { "\($0)" } // Hour labels
            fetchHourly(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityType) { hourlyData in
                completion(hourlyData) // Return hourly data
            }

        case .week:
            // Calculate startDate for the past 7 days, starting from today
            startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: endDate))! // This gives
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE" // Format for abbreviated weekday names
            labels = (0..<7).map {
                let date = calendar.date(byAdding: .day, value: $0, to: startDate)!
                return dateFormatter.string(from: date)
            }

//            print("adjustedStartDate: \(adjustedStartDate), adjustedEndDate: \(adjustedEndDate)")
            print("labels: \(labels)")
            fetchDaily(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityType) { dailyData in
                completion(dailyData) // 返回每日数据
            }
            
        case .month:
            // Start date is set to 30 days before today
            startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!

            // Generate labels for the past 30 days including today
            labels = (0..<31).map { dayOffset in
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: endDate)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd" // Change format to include month and day
                return dateFormatter.string(from: date)
            }.reversed()
            // Fetch daily data
            fetchDaily(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityType) { dailyData in
                completion(dailyData) // Return daily data
            }
            
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: endDate)!
            
            // Create an array of the last six months (including the current month)
            let months = (0..<6).map { calendar.date(byAdding: .month, value: -$0, to: endDate)! }
            
            // Create month labels using abbreviated month names
            labels = months.compactMap {
                let monthIndex = calendar.component(.month, from: $0) - 1 // Get month index
                return calendar.shortMonthSymbols[monthIndex] // Use short month names (e.g., Jan, Feb)
            }.reversed() // Reverse to have the labels in chronological order
            
            // Fetch the monthly data using the start date and end date
            fetchMonthly(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityType) { monthlyData in
                completion(monthlyData) // Return the fetched monthly data
            }
            
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
            
            // Create an array of the last 12 months (including the current month)
            let months = (0..<12).map { calendar.date(byAdding: .month, value: -$0, to: endDate)! }
            
            // Create month labels using abbreviated month names
            labels = months.compactMap {
                let monthIndex = calendar.component(.month, from: $0) - 1 // Get month index
                return calendar.shortMonthSymbols[monthIndex] // Use short month names (e.g., Jan, Feb)
            }.reversed() // Reverse to have the labels in chronological order
            
            // Fetch the monthly data using the start date and end date
            fetchMonthly(startDate: startDate, endDate: endDate, labels: labels, activity: activity, activityType: activityType) { monthlyData in
                completion(monthlyData) // Return the fetched monthly data
            }

        }
        

    }
    /// 获取每日的数据
    private func fetchDaily(startDate: Date, endDate: Date, labels: [String], activity: Activity, activityType: HKObjectType, completion: @escaping ([LineChartData]) -> Void) {
        var dailyValues: [Double] = Array(repeating: 0.0, count: labels.count)
        let numberOfDays = labels.count
        let calendar = Calendar.current
        let group = DispatchGroup() // To wait for all queries to complete

        for day in 0..<numberOfDays {
            // Calculate dayStart as the start of the day for `endDate`
            guard let dayStart = calendar.date(byAdding: .day, value: -day, to: endDate)?.startOfDay,
                  let dayEnd = calendar.date(byAdding: .second, value: -1, to: calendar.date(byAdding: .day, value: 1, to: dayStart)!) else {
                print("Error calculating date range for day \(day)")
                continue
            }

            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            print("day: \(day), dayStart: \(dayStart), dayEnd: \(dayEnd)") // Print the adjusted start and end dates

            let options = activity.statisticsOption

            if activity == .sleep {
                // Use HKSampleQuery for sleep activity
                let query = HKSampleQuery(sampleType: activityType as! HKSampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    
                    defer { group.leave() }
                    
                    guard error == nil else {
                        print("Error fetching sleep data: \(String(describing: error))")
                        return
                    }

                    // Process sleep samples
                    var totalSleepTime = 0.0
                    if let samples = results as? [HKCategorySample] {
                        for sample in samples {
                            totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate) // Calculate sleep duration
                        }
                    }

                    // Store the total sleep time for the current day
                    dailyValues[numberOfDays - 1 - day] = totalSleepTime / 3600.0 // Convert seconds to hours
                    print("Data for day \(numberOfDays - 1 - day): \(dailyValues[numberOfDays - 1 - day]) hours of sleep")
                }
                group.enter() // Notify that a query is starting
                healthStore.execute(query)
            } else {
                // Use HKStatisticsQuery for other activities
                let query = HKStatisticsQuery(quantityType: activityType as! HKQuantityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                    
                    defer { group.leave() }
                    
                    var value = 0.0
                    switch activity {
                    case .steps, .daylight:
                        if let sumQuantity = result?.sumQuantity() {
                            value = sumQuantity.doubleValue(for: activity.unit!)
                        }
                    case .noise, .hrv:
                        if let avgQuantity = result?.averageQuantity() {
                            value = avgQuantity.doubleValue(for: activity.unit!)
                        }
                    case .sleep:
                        value = 0.0 // This case should not be hit as we are already checking for sleep above
                    }
                    
                    // Store the value for the current day
                    dailyValues[numberOfDays - 1 - day] = value
                    print("Data for day \(numberOfDays - 1 - day): \(value)")
                }

                group.enter() // Notify that a query is starting
                healthStore.execute(query)
            }
        }

        // Create LineChartData and call completion when all queries are done
        group.notify(queue: .main) {
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: dailyValues[$0]) }
            print("Daily activity: \(lineChartData)")
            completion(lineChartData)
        }
    }

    
    // fetch hourly
    private func fetchHourly(startDate: Date, endDate: Date, labels: [String], activity: Activity, activityType: HKObjectType, completion: @escaping ([LineChartData]) -> Void) {
        var hourlyValues: [Double] = Array(repeating: 0.0, count: 24)
        let group = DispatchGroup() // To wait for all queries to complete
        
        for hour in 0..<24 {
            // Calculate the start and end times for each hour
            guard let hourStart = Calendar.current.date(bySetting: .hour, value: hour, of: startDate),
                  let hourEnd = Calendar.current.date(bySetting: .hour, value: hour + 1, of: startDate) else {
                print("Error calculating hour range for hour \(hour)")
                continue
            }
            
            // Define a predicate for the hour range
            let predicate = HKQuery.predicateForSamples(withStart: hourStart, end: hourEnd, options: .strictStartDate)
            
            // Determine query type based on activity
            if activity == .sleep {
                // Use HKSampleQuery for sleep activity
                let query = HKSampleQuery(sampleType: activityType as! HKSampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    
                    defer { group.leave() }
                    
                    guard error == nil else {
                        print("Error fetching sleep data: \(String(describing: error))")
                        return
                    }
                    
                    // Process sleep samples
                    var totalSleepTime = 0.0
                    if let samples = results as? [HKCategorySample] {
                        for sample in samples {
                            totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate) // Calculate sleep duration
                        }
                    }
                    
                    hourlyValues[hour] = totalSleepTime / 3600.0 // Convert seconds to hours
                    print("Data for hour \(hour): \(hourlyValues[hour]) hours of sleep")
                }
                group.enter() // Notify that a query is starting
                healthStore.execute(query)
            } else {
                // Use HKStatisticsQuery for other activities
                let query = HKStatisticsQuery(quantityType: activityType as! HKQuantityType, quantitySamplePredicate: predicate, options: activity.statisticsOption) { _, result, error in
                    
                    defer { group.leave() }
                    
                    var value = 0.0
                    switch activity {
                    case .steps, .daylight:
                        if let sumQuantity = result?.sumQuantity() {
                            value = sumQuantity.doubleValue(for: activity.unit!)
                        }
                    case .noise, .hrv:
                        if let avgQuantity = result?.averageQuantity() {
                            value = avgQuantity.doubleValue(for: activity.unit!)
                        }
                    case .sleep:
                        value = 0.0 // This case should not be hit as we are already checking for sleep above
                    }
                    hourlyValues[hour] = value
                    print("Data for hour \(hour): \(value)")
                }
                group.enter() // Notify that a query is starting
                healthStore.execute(query)
            }
            // Notify when all queries are complete
            group.notify(queue: .main) {
                let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: hourlyValues[$0]) }
                print("Hourly activity: \(lineChartData)")
                completion(lineChartData)
            }
        }
    }
    
    
    /// 获取每月的数据
    private func fetchMonthly(startDate: Date, endDate: Date, labels: [String], activity: Activity, activityType: HKObjectType, completion: @escaping ([LineChartData]) -> Void) {
        var monthlyValues: [Double] = Array(repeating: 0.0, count: labels.count)
        let numberOfMonths = labels.count
        let calendar = Calendar.current
        let group = DispatchGroup() // DispatchGroup to wait for all queries to complete

        for month in 0..<numberOfMonths {
            // Get the start of the month
            guard let monthStart = calendar.date(byAdding: .month, value: -month, to: endDate),
                  let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart)),
                  let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
                  let monthEnd = calendar.date(byAdding: .second, value: -1, to: nextMonthStart) else {
                print("Error calculating date range for month \(month)")
                continue
            }
            
            print("month: \(month) monthStart: \(startOfMonth), monthEnd: \(monthEnd)")
            let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: monthEnd, options: .strictStartDate)
            
            group.enter() // Notify that a query is starting

            // Check if the activity is sleep
            if activity == .sleep {
                let query = HKSampleQuery(sampleType: activityType as! HKSampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                    
                    defer { group.leave() } // Ensure the group leave is called

                    guard error == nil else {
                        print("Error fetching sleep data: \(String(describing: error))")
                        return
                    }

                    var totalSleepTime = 0.0
                    if let samples = results as? [HKCategorySample] {
                        for sample in samples {
                            totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate) // Calculate sleep duration
                        }
                    }

                    monthlyValues[month] = totalSleepTime / 3600.0 // Convert seconds to hours
                    print("Data for month \(month): \(monthlyValues[month]) hours of sleep")
                }
                healthStore.execute(query)
            } else {
                let options = activity.statisticsOption
                let query = HKStatisticsQuery(quantityType: activityType as! HKQuantityType, quantitySamplePredicate: predicate, options: options) { _, result, error in
                    
                    defer { group.leave() } // Ensure the group leave is called

                    guard error == nil else {
                        print("Error fetching activity data: \(String(describing: error))")
                        return
                    }

                    var value = 0.0
                    switch activity {
                    case .steps, .daylight:
                        if let sumQuantity = result?.sumQuantity() {
                            value = sumQuantity.doubleValue(for: activity.unit!)
                        }
                    case .noise, .hrv:
                        if let avgQuantity = result?.averageQuantity() {
                            value = avgQuantity.doubleValue(for: activity.unit!)
                        }
                    default:
                        value = 0.0
                    }
                    monthlyValues[month] = value
                    print("Data for month \(month): \(value)")
                }
                healthStore.execute(query)
            }
        }
        
        // Move group.notify outside the for loop to wait for all queries to complete
        group.notify(queue: .main) {
            print("monthlyValues: \(monthlyValues)")
            monthlyValues = monthlyValues.reversed()
            let lineChartData = labels.enumerated().map { LineChartData(date: $1, value: monthlyValues[$0]) }
            print("Monthly activity: \(lineChartData)")
            completion(lineChartData)
        }
    }

}
