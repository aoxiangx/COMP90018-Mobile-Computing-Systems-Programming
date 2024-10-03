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
    var icon: ImageResource
    var title: String
    var subtitle: String
    var description: String
    var paddingSapce: CGFloat // 用于控制padding大小
    let activity: Activity // Add this property
}


struct SummaryBoxesView: View {
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // 创建方块的数据集合
    let boxes = [
        BoxData(color: Constants.white, icon: .sunLightIcon, title: "Daylight Time", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 40,activity: .daylight),
        BoxData(color: Constants.white, icon: .greenSpaceIcon, title: "Green Space Time", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 0,activity: .hrv),
        BoxData(color: Constants.white, icon: .noise, title: "Noise Level", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 56,activity: .noise),
        BoxData(color: Constants.white, icon: .sleep, title: "Sleep Time", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 50,activity: .hrv),
        BoxData(color: Constants.white, icon: .stress, title: "Stress Level", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 50,activity: .hrv),
        BoxData(color: Constants.white, icon: .activeIndexIcon, title: "Actice Index", subtitle: "24 Min", description: "Past 7 Days", paddingSapce: 50,activity: .steps)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(boxes) { box in
                NavigationLink(destination:
                    GroupingDataView(activity: box.activity)
                        .environmentObject(HealthManager())
                ) { // Closing parenthesis moved here
                    SummeryBoxView(
                        color: box.color,
                        icon: box.icon,
                        title: box.title,
                        subtitle: box.subtitle,
                        description: box.description,
                        paddingSapce: box.paddingSapce // Pass the padding space
                    )
                    .frame(height: 142) // Ensure consistent box height
                }
            }
        }
        .padding() // 设置整体网格的内边距
    }
}



#Preview {
    SummaryBoxesView().environmentObject(HealthManager())
}

