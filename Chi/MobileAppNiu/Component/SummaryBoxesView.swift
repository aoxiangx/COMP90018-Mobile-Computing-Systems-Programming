//
//  SummaryBoxesView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/9/2024.
//

import SwiftUI

struct BoxData: Identifiable {
    var id = UUID()
    var color: Color
    var icon: String
    var title: String
    var subtitle: String
    var description: String
    var paddingSapce: CGFloat // 用于控制padding大小
}


struct SummaryBoxesView: View {
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // 创建方块的数据集合
    let boxes = [
        BoxData(color: .white, icon: "star", title: "Daylight Time", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 40),
        BoxData(color: .white, icon: "heart", title: "Green Space Time", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 0),
        BoxData(color: .white, icon: "bolt", title: "Noise Level", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 56),
        BoxData(color: .white, icon: "moon", title: "Sleep Time", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 50),
        BoxData(color: .white, icon: "sun.max", title: "Stress Level", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 50),
        BoxData(color: .white, icon: "cloud", title: "Actice Index", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 50)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(boxes) { box in
                SummeryBoxView(
                    color: box.color,
                    icon: box.icon,
                    title: box.title,
                    subtitle: box.subtitle,
                    description: box.description,
                    paddingSapce: box.paddingSapce // 传入paddingSapce
                )
                .frame(height: 142) // 确保方块的高度一致
                
            }
        }
        .padding() // 设置整体网格的内边距
    }
}



#Preview {
    SummaryBoxesView()
}
