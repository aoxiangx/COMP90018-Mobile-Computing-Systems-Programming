//
//  SummaryBoxView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/9/2024.
//

import SwiftUI


struct SummeryBoxView: View {
    var color: Color = .white  // 默认背景颜色
    var icon: ImageResource = .sunLightIcon // 默认图标
    var title: String = "Noise Level" // 第一个文本
    var subtitle: String = "24 Min" // 第二个文本
    var description: String = "Past 7 Days" // 第三个文本
    var paddingSapce: CGFloat = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) { // 上下排列，左对齐
            Image(icon)
                .resizable() // Make the image resizable
                .frame(width: 32, height: 32) // Set the size to 32x32
                .foregroundColor(.gray)
            // Noise Level
            Text(title)
                .font(.system(size: 16))
            
                .foregroundColor(Constants.gray3)
            
            // 24 MIin
            Text(subtitle)
//                .font(.headline)
                .font(.system(size: 24))
                .foregroundColor(Constants.gray3)
            
            // past 7 days
            Text(description)
//                .font(.caption)
                .font(.system(size: 12))
                .foregroundColor(Constants.gray3)
        }
        .padding(.trailing, paddingSapce)
        .frame(width: 172, height: 142) // 设置固定宽度和高度
        .background(color) // 背景颜色
        .cornerRadius(12) // 圆角
        .overlay(
            RoundedRectangle(cornerRadius: 12) // 与背景一致的圆角
                .stroke(Constants.gray4, lineWidth: 1) // 灰色边框，宽度2
        )
        .shadow(radius: 1) // 阴影
    }
}


#Preview {
    SummeryBoxView()
}

