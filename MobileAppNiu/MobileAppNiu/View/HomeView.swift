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
//    @AppStorage("log_Status") private var logStatus: Bool = true
    
    var body: some View {
        NavigationStack{
            Button("logOut"){
//                try? Auth.auth().signOut()
//                logStatus = false
            }.onAppear(){
                manager.fetchTodaySteps()
            }
            .navigationTitle("Home")
        }
        

    }
}

#Preview {
    HomeView()
}


