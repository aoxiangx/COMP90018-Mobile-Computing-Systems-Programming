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
}
