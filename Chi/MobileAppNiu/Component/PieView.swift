//
//  PieView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 21/9/2024.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct PieView: View {
    let percentage: Double // 输入的百分比

    var body: some View {
        ZStack {
            // 黄色顶部饼图
            Canvas { context, size in
                let total = 100.0 // 总百分比
                let startAngle: Double = 90.0 // 起始角度
                let endAngle = startAngle + (percentage / total) * 360 // 计算结束角度

                // 创建黄色饼图的路径
                let yellowPath = Path { path in
                    path.move(to: CGPoint(x: size.width / 2, y: size.height / 2)) // 圆心
                    path.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2),
                                radius: min(size.width, size.height) / 2,
                                startAngle: Angle(degrees: startAngle),
                                endAngle: Angle(degrees: endAngle),
                                clockwise: false)
                    path.addLine(to: CGPoint(x: size.width / 2, y: size.height / 2)) // 闭合路径
                }
                
                // 填充黄色饼图颜色
                context.fill(yellowPath, with: .color(Constants.Yellow2))
                
                // 添加黑色边框
                context.stroke(yellowPath, with: .color(Constants.gray3), lineWidth: 0.2) // 黑色边框
            }
            .frame(width: 32, height: 32) // 黄色饼图的视图大小
        }
    }
}
#Preview {
    PieView(percentage: 35) // 示例数据
}
