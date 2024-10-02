//
//  ObjectiveNotification.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 23/9/2024.
//

import SwiftUI

struct ObjectiveNotification: View {
    @State private var currentProgress: Double // 当前进度百分比
    var currentTime: Int // 当前的时间（未来可以连接到真实数据）
    var objectiveTime: Int? // 用户设置的目标时间，可能为nil
    
    init(currentTime: Int, objectiveTime: Int?) {
        self.currentTime = currentTime
        self.objectiveTime = objectiveTime ?? 0
        self.currentProgress = objectiveTime != nil ? Double(currentTime) / Double(objectiveTime!) : 0.0
    }

    var body: some View {
        VStack {
            if let objective = objectiveTime, objective > 0 {
                // 显示真实进度和目标
                Text("Notice: You haven’t had enough sunlight time in the past week!")
                    .font(Constants.caption)
                    .foregroundColor(Constants.gray3)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        HStack(alignment: .bottom){
                            Image("Sun_Light_Icon")
                                .resizable()
                                .padding(8)
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daylight Time ")
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                                Text("\(currentTime) Min") // 显示当前时间
                                    .font(Font.custom("Roboto", size: 24))
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
                                .frame(width: min(self.currentProgress * geometry.size.width, geometry.size.width), height: 20)
                                .foregroundColor(Constants.Yellow1)
                                .animation(.linear, value: currentProgress)
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
                // 没有设置目标的通知
                Text("You haven't set any objective for sunlight exposure.")
                    .font(Constants.caption)
                    .foregroundColor(Constants.gray3)
                    .padding()

                Button(action: {
                    // 添加跳转到设置页面的动作
                }) {
                    Text("Set Objective")
                        .font(Font.custom("Roboto", size: 16))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
    }
}


#Preview {
    ObjectiveNotification(currentTime: 20, objectiveTime: 40) // 当前时间20分钟，目标时间40分钟，显示50%进度
}
