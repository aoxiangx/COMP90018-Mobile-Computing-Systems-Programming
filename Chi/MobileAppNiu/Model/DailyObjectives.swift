//
//  DailyObjectives.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 2/10/2024.
//

import Foundation

struct DailyObjectives: Codable {
    var sunlightDuration: Int  // 日照时间（分钟）
    var greenAreaActivityDuration: Int  // 绿地活动时间（分钟）
    var totalActivityDuration: Int  // 总活动时间（分钟）
    
}

extension UserDefaults {
    func setDailyObjectives(_ objectives: DailyObjectives, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(objectives) {
            set(encoded, forKey: key)
        }
    }

    func getDailyObjectives(forKey key: String) -> DailyObjectives? {
        if let data = object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(DailyObjectives.self, from: data)
        }
        return nil
    }
}
