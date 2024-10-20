//
//  GreenSpaceTimeManager.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/10/2024.
//

import Foundation

@MainActor
class GreenSpaceTimeManager {
    
    private let locationManager = LocationManager.shared
    
    init(){}
    
    func fetchGreenSpaceTimes(for timePeriod: TimePeriod) -> ([String], [Double]) {
        var greenSpaceTimes: [Double] = []
        var labels: [String] = []
        let today = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        // Get green space times based on the time period
        switch timePeriod {
        case .day:
            labels = (0..<24).map { "\($0)" } // Hour labels
            greenSpaceTimes = locationManager.getGreenSpaceTimes(forLastNDays: 1)

        case .week:
            dateFormatter.dateFormat = "EEE" // Abbreviated weekday names
            labels = (0..<7).map {
                let date = calendar.date(byAdding: .day, value: -$0, to: today)!
                return dateFormatter.string(from: date)
            }.reversed() // Order from past to today
            greenSpaceTimes = locationManager.getGreenSpaceTimes(forLastNDays: 7)

        case .month:
            dateFormatter.dateFormat = "MM/dd" // Month and day format
            labels = (0..<30).map {
                let date = calendar.date(byAdding: .day, value: -$0, to: today)!
                return dateFormatter.string(from: date)
            }.reversed() // Order from past to today
            greenSpaceTimes = locationManager.getGreenSpaceTimes(forLastNDays: 30)

        case .sixMonths:
            let months = (0..<6).map { calendar.date(byAdding: .month, value: -$0, to: today)! }
            labels = months.compactMap {
                dateFormatter.dateFormat = "MMM" // Abbreviated month names
                return dateFormatter.string(from: $0)
            }.reversed() // Order from past to today
            greenSpaceTimes = locationManager.getGreenSpaceTimes(forLastNDays: 180)

        case .year:
            let months = (0..<12).map { calendar.date(byAdding: .month, value: -$0, to: today)! }
            labels = months.compactMap {
                dateFormatter.dateFormat = "MMM" // Abbreviated month names
                return dateFormatter.string(from: $0)
            }.reversed() // Order from past to today
            greenSpaceTimes = locationManager.getGreenSpaceTimes(forLastNDays: 365)
        }

        return (labels, greenSpaceTimes)
    }

}
