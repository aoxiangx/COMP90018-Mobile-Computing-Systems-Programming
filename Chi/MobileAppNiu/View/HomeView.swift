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
    
    @State private var currentPageIndex = 0
    let totalPages = 3

    
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

                    VStack {
                        // TabView 实现左右滑动的 ObjectiveNotification 列表
                        TabView(selection: $currentPageIndex) {
                            ObjectiveNotification(
                                currentTime: 5,
                                objectiveTime: objectiveViewModel.objectives.sunlightDuration,
                                objectiveType: "Daylight time"
                            )
                            .tag(0)

                            ObjectiveNotification(
                                currentTime: 45,
                                objectiveTime: objectiveViewModel.objectives.greenAreaActivityDuration,
                                objectiveType: "Green Space Time"
                            )
                            .tag(1)

                            ObjectiveNotification(
                                currentTime: 80,
                                objectiveTime: objectiveViewModel.objectives.totalActivityDuration,
                                objectiveType: "Active Index"
                            )
                            .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 300)

                        // 分页指示器距离 TabView 更近
                        HStack {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(currentPageIndex == index ? Color.blue : Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, -70)  // 调整分页指示器与 TabView 之间的距离
                    }
                }
            }
        }
    }
    
    
}
#Preview {
    HomeView()
        .environmentObject(HealthManager())
}
