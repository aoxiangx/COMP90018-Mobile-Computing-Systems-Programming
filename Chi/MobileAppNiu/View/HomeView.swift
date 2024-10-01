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
        
        ZStack (alignment: .topLeading){
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
                }
                .onAppear {
                    manager.fetchTodayNoiseLevels()
                }
//                .navigationTitle("Home")
                .padding(.leading, 16)
                
                VStack(alignment: .center){
                    ScoreEmoji(score:89)
                }
                ObjectiveNotification()
                    .padding(16)
                SummaryBoxesView().environmentObject(HealthManager())
            }
            

        }
    }
}


#Preview {
    HomeView()
        .environmentObject(HealthManager())
}
