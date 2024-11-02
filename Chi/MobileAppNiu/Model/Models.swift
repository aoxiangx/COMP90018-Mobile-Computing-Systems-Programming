//
//  Models.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 12/10/2024.
//


import Foundation
import HealthKit
import SwiftUI

class SharedData: ObservableObject {
    @Published var percentages: [Double] = Array(repeating: 0.0, count: 7)
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
struct ObjectiveData: Identifiable {
    var id = UUID()
    var color: Color
    var icon: ImageResource
    var title: String
    var subtitle: String
    var objectiveTime: Int
    var paddingSpace: CGFloat // 用于控制 padding 大小
    let activity: Activity // 添加此属性
}

enum Activity {
    case steps
    case daylight
    case noise
    case hrv
    case sleep
    case green
    
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
        case .green:
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
        case .green:
            return nil
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
        case .green:
            return []
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
        case .green:
            return "Green Space Time"
        }
    }
    
    var suggestions: [String] {
        switch self {
        case .steps:
            return ["Take a Walk in the Park", "Go for a Run when it's Sunny"]
        case .daylight:
            return ["Spend Time in Natural Sunlight", "Go Outside for Fresh Air"]
        case .noise:
            return ["Find a Quiet Spot to Relax", "Use Noise-Canceling Headphones"]
        case .hrv:
            return ["Practice Deep Breathing Exercises", "Try Meditation to Reduce Stress"]
        case .sleep:
            return ["Stick to a Consistent Sleep Schedule", "Create a Relaxing Bedtime Routine"]
        case .green:
            return ["Visit a Nearby Park or Nature Reserve", "Take a Break and Enjoy Green Spaces"]
        }
    }
    
    var reason: String {
        switch self {
        case .steps:
            return "Physical activity like walking or running strengthens your cardiovascular system, improves muscle tone, and boosts overall energy levels. It also stimulates the release of endorphins, improving mood and reducing stress. Regular steps help maintain a healthy weight, increase stamina, and enhance brain function, keeping you physically and mentally sharp."
        case .daylight:
            return "Sunlight does more than just light up your day—it's essential for mental wellness, helping to balance and energize you. Sunlight increases serotonin, boosting mood and calmness. It also aligns sleep-wake cycles for better rest and refreshment. As a key player in vitamin D production, sunlight supports brain health and maintains high energy levels. Additionally, exposure to natural light sharpens focus and enhances cognitive function, helping you think more clearly and perform better. Embrace natural light to uplift your mental health!"
        case .noise:
            return "Excessive noise can lead to heightened stress, anxiety, and difficulty concentrating. Reducing noise exposure promotes calmness, improves focus, and lowers blood pressure. Quiet environments are essential for better mental clarity, improved productivity, and enhanced overall well-being. Protect your hearing and mental peace by managing the noise levels around you."
        case .hrv:
            return "Heart Rate Variability (HRV) is a key indicator of stress and overall heart health. Maintaining a healthy HRV reflects strong emotional resilience and a balanced autonomic nervous system. By engaging in activities that reduce stress, such as mindfulness or breathing exercises, you can improve your HRV, leading to better emotional control, enhanced focus, and a healthier heart."
        case .sleep:
            return "Quality sleep is vital for your body to repair and rejuvenate. It strengthens the immune system, improves memory and cognitive function, and balances emotions. Poor sleep affects mood, concentration, and physical health. By getting consistent and restful sleep, you'll wake up energized, with better mental clarity and emotional stability."
        case .green:
            return "Spending time in green spaces improves mental health by reducing stress, enhancing mood, and boosting cognitive function. Nature exposure helps lower anxiety and depression symptoms, while also encouraging physical activity. The peaceful atmosphere of green spaces promotes relaxation, creativity, and an overall sense of well-being."
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
        case .green:
            return "Minutes"
        }
    
    }
//    var objectiveInfo: BoxData {
//        switch self {
//        case .steps:
//            return BoxData(color: Constants.Red, icon: .activeIndexIcon, title: "Active Index", subtitle: "Step(s)", description: "Past 7 Days", paddingSpace: 50, activity: .steps)
//        case .daylight:
//            return BoxData(color: Constants.Yellow1, icon: .sunLightIcon, title: "Daylight Time", subtitle: "Min(s)", description: "Past 7 Days", paddingSpace: 40, activity: .daylight)
//        case .noise:
//            return BoxData(color: Constants.Blue1, icon: .noise, title: "Noise Level", subtitle: "dB", description: "Past 7 Days", paddingSpace: 56, activity: .noise)
//        case .hrv:
//            return BoxData(color: Constants.Blue3, icon: .stress, title: "Stress Level", subtitle: "Pascals", description: "Past 7 Days", paddingSpace: 50, activity: .hrv)
//        case .sleep:
//            return BoxData(color: Constants.Blue2, icon: .sleep, title: "Sleep Time", subtitle: "Hour(s)", description: "Past 7 Days", paddingSpace: 50, activity: .sleep)
//        }
//    }
    func objectiveInfo(viewModel: ObjectiveViewModel) -> ObjectiveData {

        let objectiveTime: Int // Define a local variable to hold the objective time
        switch self {
        case .steps:
            objectiveTime = viewModel.objectives.stepCount
            return ObjectiveData(color: Constants.Red, icon: .activeIndexIcon, title: "Active Index", subtitle: "Step(s)", objectiveTime: objectiveTime, paddingSpace: 50, activity: .steps)
            
        case .daylight:
            objectiveTime = viewModel.objectives.sunlightDuration
            return ObjectiveData(color: Constants.Yellow1, icon: .sunLightIcon, title: "Daylight Time", subtitle: "Min(s)", objectiveTime: objectiveTime, paddingSpace: 40, activity: .daylight)
            
        case .noise:
            objectiveTime = viewModel.objectives.greenAreaActivityDuration
            return ObjectiveData(color: Constants.Blue1, icon: .noise, title: "Noise Level", subtitle: "dB", objectiveTime: objectiveTime, paddingSpace: 56, activity: .noise)
            
        case .hrv:
            objectiveTime = viewModel.objectives.sunlightDuration
            return ObjectiveData(color: Constants.Blue3, icon: .stress, title: "Stress Level", subtitle: "Pascals", objectiveTime: objectiveTime, paddingSpace: 50, activity: .hrv)
            
        case .sleep:
            objectiveTime = viewModel.objectives.stepCount
            return ObjectiveData(color: Constants.Blue2, icon: .sleep, title: "Sleep Time", subtitle: "Hour(s)", objectiveTime: objectiveTime, paddingSpace: 50, activity: .sleep)
            
        case .green:
            objectiveTime = viewModel.objectives.greenAreaActivityDuration
            return ObjectiveData(color: Constants.Blue2, icon: .greenSpaceIcon, title: "Green Space Time", subtitle: "Min(s)", objectiveTime: objectiveTime, paddingSpace: 50, activity: .sleep)
        }
    }


    func dayValue(using manager: HealthManager, completion: @escaping (Double?, Error?) -> Void) {
            switch self {
            case .steps:
                manager.fetchTodaySteps { (steps, error) in
                    completion(steps, error)
                }
            case .hrv:
                manager.fetchTodayHRV { (hrv, error) in
                    completion(hrv, error)
                }
            case .sleep:
                manager.fetchTodaySleep { (sleep, error) in
                    completion(sleep, error)
                }
            case .daylight:
                manager.fetchTodayDaylight { (daylight, error) in
                    completion(daylight, error)
                }
            case .noise:
                manager.fetchTodayNoiseLevels { (noise, error) in
                    completion(noise, error)
                }
            case .green:
                manager.fetchTodayNoiseLevels { (daylight, error) in
                    completion(daylight, error)
                }
            }
        }
}

