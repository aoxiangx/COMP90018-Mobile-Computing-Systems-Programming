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
    case sleep
    
    var activityType: HKObjectType {
        switch self {
        case .steps:
            return HKQuantityType.quantityType(forIdentifier: .stepCount)!
        case .daylight:
            return HKQuantityType.quantityType(forIdentifier: .timeInDaylight)!
        case .noise:
            return HKQuantityType.quantityType(forIdentifier: .environmentalAudioExposure)!
        case .hrv:
            return HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        case .sleep:
            return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        }
    }
    
    var unit: HKUnit? {
        switch self {
        case .steps:
            return HKUnit.count()
        case .daylight:
            return HKUnit.minute()
        case .noise:
            return HKUnit.decibelAWeightedSoundPressureLevel()
        case .hrv:
            return HKUnit.secondUnit(with: .milli)
        case .sleep:
            return nil  // Sleep does not have a unit like the others
        }
    }
    
    var statisticsOption: HKStatisticsOptions {
        switch self {
        case .steps, .daylight:
            return .cumulativeSum
        case .noise, .hrv:
            return .discreteAverage
        case .sleep:
            return []  // No statistics options for sleep
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
        case .sleep:
            return "Sleep Time"
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
        case .sleep:
            return "Hours"
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
    case sixMonths = "6Ms"
    case year = "Year"
}

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}
