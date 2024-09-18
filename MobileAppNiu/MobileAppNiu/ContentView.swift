//
//  ContentView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        HomeView()
//        if logStatus{
//            HomeView()
//        } else{
//            LoginView()
//        }
    }
}


#Preview {
    ContentView()
}


