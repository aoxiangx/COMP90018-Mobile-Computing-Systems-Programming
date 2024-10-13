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
    var paddingSpace: CGFloat // 用于控制 padding 大小
    let activity: Activity // 添加此属性
}

struct SummaryBoxesView: View {
    @EnvironmentObject var manager: HealthManager

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    // 创建方块的数据集合
    let boxes = [
        BoxData(color: Constants.white, icon: .sunLightIcon, title: "Daylight Time", subtitle: "Min(s)", description: "Past 7 Days", paddingSpace: 40, activity: .daylight),
        BoxData(color: Constants.white, icon: .greenSpaceIcon, title: "Green Space Time", subtitle: "Min(s)", description: "Past 7 Days", paddingSpace: 0, activity: .daylight),
        BoxData(color: Constants.white, icon: .noise, title: "Noise Level", subtitle: "dB", description: "Past 7 Days", paddingSpace: 56, activity: .noise),
        BoxData(color: Constants.white, icon: .sleep, title: "Sleep Time", subtitle: "Min(s)", description: "Past 7 Days", paddingSpace: 50, activity: .daylight),
        BoxData(color: Constants.white, icon: .stress, title: "Stress Level", subtitle: "Pascals", description: "Past 7 Days", paddingSpace: 50, activity: .daylight),
        BoxData(color: Constants.white, icon: .activeIndexIcon, title: "Active Index", subtitle: "Step(s)", description: "Past 7 Days", paddingSpace: 50, activity: .steps)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(boxes) { box in
                NavigationLink(destination:
                                GroupingDataView(activity: box.activity, icon: box.icon).environmentObject(manager)
                ) {
                    SummeryBoxView(
                        color: box.color,
                        icon: box.icon,
                        title: box.title,
                        subtitle: box.subtitle,
                        description: box.description,
                        paddingSpace: box.paddingSpace,
                        activity: box.activity
                    )
                    .frame(height: 142) // 确保一致的方块高度
                }
            }
        }
        .padding() // 设置整体网格的内边距
    }
}

struct SummaryBoxesView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryBoxesView()
            .environmentObject(HealthManager()) // 在预览中注入 HealthManager
    }
}
