//
//  HomeView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var manager : HealthManager
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    // 引入 ObjectiveViewModel
    @StateObject private var objectiveViewModel = ObjectiveViewModel()
    
    var body: some View {
        VStack {
            
//            LinearGradient(gradient: Gradient(stops: [
//                .init(color: Color(hex: "FFF8C9"), location: 0.0),  // 开始颜色 FFF8C9
//                .init(color: Color(hex: "EDF5FF"), location: 0.6)   // 结束颜色 EDF5FF
//            ]),
//                           startPoint: .topLeading,
//                           endPoint: .bottomTrailing)
//            .edgesIgnoringSafeArea(.all)  // 填满整个屏幕
            
            // 页面内容
            //            GroupingDataView().environmentObject(manager)
            //            Button("Niu Niu") {
            //                manager.fetchTimeIntervalSteps(timePeriod: .week)
            //            }
            //            Button("haha") {
            //                manager.fetchTimeIntervalSteps(timePeriod: .day)
            //            }.padding(20)
            //
            //            Button("yeye") {
            //                manager.fetchTimeIntervalSteps(timePeriod: .year)
            //            }.padding(20)
            //
            //        }
            
            ZStack (alignment: .topLeading){
                // 背景
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFF8C9"), location: 0.0),  // 开始颜色 FFF8C9
                    .init(color: Color(hex: "EDF5FF"), location: 0.6)   // 结束颜色 EDF5FF
                ]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)  // 填满整个屏幕
                
                VStack(alignment: .leading){
                    // Date view
                    DateHomeView()
                    
                    PieHomeView(percentages: [35, 50, 65, 75, 85, 90, 55]).padding(.leading, 15)
                    
                    
                    // button
                    Button("Fetch Steps") {
                        manager.fetchTodaySteps()
                    }


                    .navigationTitle("Home")
                    .padding(.leading, 15)
                    
                    
                    PhotoButtonView()
                    ScoreEmojiView(score: 45)
                    // 使用 TabView 实现左右滑动的 ObjectiveNotification 列表
                    TabView {
                        // 日照时间的目标
                        ObjectiveNotification(
                            currentTime: 5,
                            objectiveTime: objectiveViewModel.objectives.sunlightDuration,
                            objectiveType: "Daylight time"
                        )
                        // 绿地活动时间的目标
                        ObjectiveNotification(
                            currentTime: 45,
                            objectiveTime: objectiveViewModel.objectives.greenAreaActivityDuration,
                            objectiveType: "Green Space Time"
                        )
                        // 总活动时间的目标
                        ObjectiveNotification(
                            currentTime: 80,
                            objectiveTime: objectiveViewModel.objectives.totalActivityDuration,
                            objectiveType: "Active Index"
                        )
                    }
                    .tabViewStyle(PageTabViewStyle()) // 使用 PageTabViewStyle 实现左右滑动效果
                    .frame(height: 300) // 设置 TabView 高度

                }
            }
        }
    }
    
    
}
#Preview {
    HomeView()
        .environmentObject(HealthManager())
}
