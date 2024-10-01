//
//  ContentView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    
    @AppStorage("log_Status") private var logStatus: Bool = false // remember to set as false
    
    var body: some View {

        
        if logStatus{
            HomeView()
                .environmentObject(HealthManager())
        } else{
            LoginView()
        }
        
    }
}


#Preview {
    ContentView()
}


