//
//  testView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 21/9/2024.
//

import SwiftUI

import SwiftUI

struct testView: View {
    @State private var progress: Double = 75.0  // 存储百分比进度

    var body: some View {
        VStack {
            ZStack {
                // 背景圆形（灰色描边）
                Circle()
                    .stroke(Color.gray, lineWidth: 20)  // 灰色边框
                    .frame(width: 198.5, height: 186)  // 设置圆的大小
                
                // 前景进度条圆形
                Circle()
                    .trim(from: 0.0, to: progress / 100)  // 根据百分比裁剪进度
                    .stroke(
                        Color.yellow,  // 设置进度条颜色
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)  // 设置圆角
                    )
                    .rotationEffect(.degrees(-90))  // 旋转进度条起始点到顶部
                    .frame(width: 198.5, height: 186)  // 设置圆的大小
                
                // 起始圆形描边
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 3))  // 灰色边框
                    .frame(width: 20, height: 20)
                    .offset(x: 0, y: -93)  // 调整位置到顶部
                
                // 结束圆形描边
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 3))  // 灰色边框
                    .frame(width: 20, height: 20)
                    .offset(x: 0, y: 93)  // 调整位置到底部
                
                // 中间显示进度百分比
                Text("\(Int(progress))%")
                    .font(.system(size: 48))
                    .bold()
            }
            .padding(20)
        }
    }
}

#Preview {
    testView()
}
