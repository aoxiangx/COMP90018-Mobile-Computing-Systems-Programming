//
//  Models.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 12/10/2024.
//



import Foundation
import HealthKit

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
    
    var unit: HKUnit {
        switch self {
        case .steps:
            return HKUnit.count()
        case .daylight:
            return HKUnit.minute()
        case .noise:
            return HKUnit.decibelAWeightedSoundPressureLevel()
        case .hrv:
            return HKUnit.secondUnit(with: .milli)
        }
    }
    
    var statisticsOption: HKStatisticsOptions {
        switch self {
        case .steps, .daylight:
            return .cumulativeSum
        case .noise, .hrv:
            return .discreteAverage
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
            return "Stress Level"
        }
    }
    
    var unitDescription: String {
        switch self {
        case .steps:
            return "Steps"
        case .daylight:
            return "Minutes"
        case .noise:
            return "dB"
        case .hrv:
            return "ms"
        }
    }
}

struct LineChartData: Identifiable {
    var id = UUID()
    var date: String
    var value: Double
}

enum TimePeriod: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case sixMonths = "Six Months"
    case year = "Year"
}
extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}
