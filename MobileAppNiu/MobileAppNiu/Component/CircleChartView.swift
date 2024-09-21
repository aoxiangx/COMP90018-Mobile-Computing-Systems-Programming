//
//  CircleChartView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 21/9/2024.
//

import SwiftUI

struct CircleChartView: View {
    @State private var progress: Double = 90.0  // 默认进度百分比
    var message: String = "Keep it up!"         // 自定义的消息

    var body: some View {
        VStack {
            
            // circle view
            ZStack {
                
                // background circle
                Circle()
                    .stroke(Color.white, lineWidth: 20)
                    .frame(width: 198.5, height: 186)
                
                // gray border circle
               Circle()
                   .trim(from: 0.0, to: progress / 100)  // 根据百分比裁剪进度
                   .stroke(
                    Constants.gray3,  // 设置进度条颜色
                       style: StrokeStyle(lineWidth: 21, lineCap: .round)  // 设置圆角
                   )
                   .rotationEffect(.degrees(130))  // 旋转进度条起始点到顶部
                   .frame(width: 198.5, height: 186)  // 设置圆的大小
                
                
                // 前景进度条圆形
               Circle()
                   .trim(from: 0.0, to: progress / 100)  // 根据百分比裁剪进度
                   .stroke(
                       Color.yellow,  // 设置进度条颜色
                       style: StrokeStyle(lineWidth: 20, lineCap: .round)  // 设置圆角
                   )
                   .rotationEffect(.degrees(130))  // 旋转进度条起始点到顶部
                   .frame(width: 198.5, height: 186)  // 设置圆的大小

                
                
                // 显示进度和消息的区域
                VStack {
                    Text("\(Int(progress))%")  // 显示百分比
                        .font(.system(size: 48))
                        .bold()
                    
                    Text(message)  // 显示消息
                        .font(.system(size: 12))
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    CircleChartView()
}

