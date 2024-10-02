//
//  ObjectiveNotification.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 23/9/2024.
//

import SwiftUI

struct ObjectiveNotification: View {
    var currentTime: Int? // 当前的时间（可能为nil）
    var objectiveTime: Int? // 用户设置的目标时间，可能为nil
    var objectiveType: String? // 目标类型，可能为nil

    init(currentTime: Int? = nil, objectiveTime: Int? = nil, objectiveType: String? = nil) {
        self.currentTime = currentTime
        self.objectiveTime = objectiveTime
        self.objectiveType = objectiveType
    }

    // 根据进度确定提示信息
    private var progressMessage: String {
        let progress = currentTime != nil && objectiveTime != nil ? Double(currentTime!) / Double(objectiveTime!) : 0
        switch progress {
        case ..<0.25:
            return "Just starting—let’s keep going!"
        case 0.25..<0.5:
            return "Nice progress, keep it up!"
        case 0.5..<0.75:
            return "You're doing great, almost there!"
        case 1.0...:
            return "Awesome job—you did it!"
        default:
            return "Stay focused and keep tracking!"
        }
    }


    // 根据目标类型决定显示的图标
    private var objectiveIcon: String {
        switch objectiveType {
        case "Daylight time":
            return "Sun_Light_Icon"
        case "Green Space Time":
            return "Green_Space_Icon" // 你需要提供对应的图标名称
        case "Active Index":
            return "Active_Index_Icon" // 你需要提供对应的图标名称
        default:
            return "Default_Icon" // 你需要提供默认图标名称
        }
    }

    // 根据目标类型决定进度条颜色
    private var progressBarColor: Color {
        switch objectiveType {
        case "Daylight time":
            return Constants.Yellow1
        case "Green Space Time":
            return Constants.Green
        case "Active Index":
            return Constants.Red
        default:
            return .gray // 默认颜色
        }
    }

    var body: some View {
        VStack {
            if let objective = objectiveTime, let current = currentTime, let objectiveType = objectiveType {
                // 显示根据进度生成的提示和目标
                Text(progressMessage)
                    .font(Constants.caption)
                    .foregroundColor(Constants.gray3)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        HStack(alignment: .bottom) {
                            Image(objectiveIcon) // 动态显示图标
                                .resizable()
                                .padding(8)
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(objectiveType.capitalized)") // 动态显示目标类型
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                                Text("\(current) Min") // 显示当前时间
                                    .font(Font.custom("Roboto", size: 24))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                                Text("per day") // 显示时间单位
                                    .font(Font.custom("Roboto", size: 12))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                            }
                            Spacer()
                            Text("Objective: \(objective) Min") // 显示目标时间
                                .font(Font.custom("Roboto", size: 12))
                                .foregroundColor(Constants.gray3)
                        }
                    }
                    // 进度条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 20)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                                .cornerRadius(10)
                            Rectangle()
                                .frame(width: min(Double(current) / Double(objective) * geometry.size.width, geometry.size.width), height: 20)
                                .foregroundColor(progressBarColor) // 根据目标类型动态设置进度条颜色
                                .animation(.linear, value: currentTime)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 21)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(Constants.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.15)
                        .stroke(Constants.gray4, lineWidth: 0.3)
                )
            } else {
                // 没有设置目标的情况，保留背景和框架
                VStack(alignment: .center, spacing: 8) {
                    Text("Press the button to set your first objective!")
                        .font(Constants.caption)
                        .foregroundColor(Constants.gray3)
                        .padding()

                    Button(action: {
                        // 跳转到设置页面的逻辑
                        print("Navigate to settings")
                    }) {
                        Text("Set Objective")
                            .font(Font.custom("Roboto", size: 16))
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Constants.white) // 保持一致的背景
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.15)
                        .stroke(Constants.gray4, lineWidth: 0.3) // 保持一致的外框
                )
            }
        }
    }
}
#Preview {
    // 测试无目标设定情况
    ObjectiveNotification()
    
    // 测试有目标设定情况
    ObjectiveNotification(currentTime: 20, objectiveTime: 100, objectiveType: "Daylight time")
    
    // 测试 green space 目标
    ObjectiveNotification(currentTime: 45, objectiveTime: 100, objectiveType: "Green Space Time")
    
    // 测试 active index 目标
    ObjectiveNotification(currentTime: 60, objectiveTime: 100, objectiveType: "Active Index")
}
