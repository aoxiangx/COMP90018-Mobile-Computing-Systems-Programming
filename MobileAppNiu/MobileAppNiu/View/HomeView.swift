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
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        Text("Hello, Brave niuniu!")
        NavigationStack{
            Button("logOut"){
                try? Auth.auth().signOut()
                logStatus = false
            }.navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
