//
//  ObjectiveViewModel.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 2/10/2024.
//

import Foundation

/// `ObjectiveViewModel` 管理用户设置的目标，包括日照时间、绿地活动时间和总活动时间。
/// 它提供了持久化保存这些目标的机制，并在应用启动时检索它们。
class ObjectiveViewModel: ObservableObject {
    /// 发布的 `objectives` 属性存储用户目标。
    /// 任何对此属性的更改都会自动将新的目标保存到 UserDefaults。
    @Published var objectives: DailyObjectives {
        didSet {
            print("目标更新: 日照时间 \(objectives.sunlightDuration) 分钟, 绿地活动时间 \(objectives.greenAreaActivityDuration) 分钟, 总活动时间 \(objectives.stepCount) 分钟")
            UserDefaults.standard.setDailyObjectives(objectives, forKey: "UserObjectives")
        }
    }
    
    /// 发布的属性，用于控制 UI 中详细信息的可见性。
    @Published var showDetail = false
    
    /// 发布的属性，跟踪当前正在编辑的目标类型。
    @Published var activeCard: ObjectiveType?

    /// 定义目标类型的枚举。
    enum ObjectiveType {
        case sunlight, greenArea, stepCount
    }
    
    /// 初始化视图模型，从 UserDefaults 加载现有目标，
    /// 如果没有找到，则使用默认值。
    init() {
        if let loadedObjectives = UserDefaults.standard.getDailyObjectives(forKey: "UserObjectives") {
            self.objectives = loadedObjectives
        } else {
            self.objectives = DailyObjectives(sunlightDuration: 30, greenAreaActivityDuration: 60, stepCount: 90)
        }
    }
    
    /// 开始编辑特定类型的目标的函数。
    /// - Parameter type: ObjectiveType 目标类型
    func editObjective(_ type: ObjectiveType) {
        activeCard = type
        showDetail = true
    }
}
