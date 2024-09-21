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
        ZStack {
            // 背景
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(hex: "FFF8C9"), location: 0.0),  // 开始颜色 FFF8C9
                .init(color: Color(hex: "EDF5FF"), location: 0.6)   // 结束颜色 EDF5FF
            ]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)  // 填满整个屏幕
            
            // 页面内容
            
            Button("Niu Niu") {
            }
            .onAppear {
                manager.fetchTodaySteps()
            }
            .navigationTitle("Home")
            
            
        }
    }
}
#Preview {
    HomeView()
        .environmentObject(HealthManager())
}
