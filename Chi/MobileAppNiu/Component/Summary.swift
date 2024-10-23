//
//  Summary.swift
//  MobileAppNiu
//
//  Created by Tori Li on 19/9/2024.
//

import SwiftUI

// 创建方块的数据集合
let boxes = [
    BoxData(color: Constants.white, icon: .sunLightIcon, title: "Daylight Time", subtitle: "Min", description: "Past 7 Days", paddingSpace: 40, activity: .daylight),
    BoxData(color: Constants.white, icon: .greenSpaceIcon, title: "Green Space Time", subtitle: "Min", description: "Past 7 Days", paddingSpace: 0, activity: .green),
    BoxData(color: Constants.white, icon: .noise, title: "Noise Level", subtitle: "dB", description: "Past 7 Days", paddingSpace: 56, activity: .noise),
    BoxData(color: Constants.white, icon: .sleep, title: "Sleep Time", subtitle: "Hours", description: "Past 7 Days", paddingSpace: 50, activity: .sleep),
    BoxData(color: Constants.white, icon: .stress, title: "Stress Level", subtitle: "ms", description: "Past 7 Days", paddingSpace: 50, activity: .hrv),
    BoxData(color: Constants.white, icon: .activeIndexIcon, title: "Active Index", subtitle: "Steps", description: "Past 7 Days", paddingSpace: 50, activity: .steps)
]

struct Summary: View {
    @EnvironmentObject var manager: HealthManager
    var body: some View {
        VStack(spacing:16){
            Text("Summary")
                .font(Font.custom("Roboto", size: 24))
                .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                .frame(maxWidth: .infinity, alignment: .topLeading)
            ForEach(boxes) { box in
                NavigationLink(destination:
                                GroupingDataView(activity: box.activity, icon: box.icon).environmentObject(manager)
                ) {
                    LandscapeInfoCard(activity: box.activity,iconName: box.icon,subtitle:box.subtitle)
                    .environmentObject(manager)
                    .frame(height: 100) // 确保一致的方块高度
                }
            }
        }
    }
}

#Preview {
    Summary().environmentObject(HealthManager())
}
