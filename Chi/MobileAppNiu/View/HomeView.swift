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
    
    var body: some View {
        
            
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
            
        NavigationView {
                    ZStack(alignment: .topLeading) {
                        // 背景渐变
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "FFF8C9"), Color(hex: "EDF5FF")]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)

                        VStack(alignment: .leading) {
                            DateHomeView()
                            
                            PieHomeView(percentages: [35, 50, 65, 75, 85, 90, 55])
                                .padding(.leading, 15)

                            Button("Fetch Steps") {
                                manager.fetchTodaySteps()
                            }
                            .padding(.leading, 15)

                            PhotoButtonView()
                            ScoreEmojiView(score: 45)
                            ObjectiveNotification()
                            NavigationLink(destination: ProfileView()){
                                Text("Profile")
                            }
                        }

                    }
                    .navigationTitle("") // 确保此处设置空标题
                    .navigationBarHidden(true) // 确保导航栏被隐藏
                }
        
    }
    
    
}
#Preview {
    HomeView()
        .environmentObject(HealthManager())
}
