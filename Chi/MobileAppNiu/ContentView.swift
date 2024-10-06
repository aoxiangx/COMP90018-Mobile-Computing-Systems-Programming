//
//  ContentView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    
    @AppStorage("log_Status") private var logStatus: Bool = true // remember to set as false
    
    
    @State private var isReflectToggled = false
    @State private var isJourneyToggled = false
    @State private var isInsightsToggled = false
    @State private var isSettingsToggled = false
    var body: some View {
        if logStatus{
            TabView {
                NavigationView {
                    HomeView().environmentObject(LocationManager())
                    
                }
                .tabItem {
                    Image(isReflectToggled ? .mindfulnessToggled : .mindfulUntoggled) // Toggle between two images
                    Text("Reflect")
                }
                .onAppear {
                    toggleTabs(reflect: true) // Toggle Reflect and untoggle others
                }
                NavigationView {
                    CalendarView()
                }
                .tabItem {
                    Image(isJourneyToggled ? .journeyToggled : .journeyUntoggled)
                    Text("Journey")
                }
                .onAppear {
                    toggleTabs(journey: true) // Toggle Journey and untoggle others
                }
                NavigationView {
                    SummaryBoxesView().environmentObject(HealthManager())
                }
                .tabItem {
                    Image(isInsightsToggled ? .insightsToggled : .insightsUntoggled)
                    Text("Insights")
                }
                .onAppear {
                    toggleTabs(insights: true) // Toggle Insights and untoggle others
                }
                NavigationView {
                    ProfileView()
                }
                .tabItem {
                    Image(isSettingsToggled ? .settingToggled : .settingUntoggled)
                    Text("Setting")
                }
                .onAppear {
                    toggleTabs(settings: true) // Toggle Settings and untoggle others
                }
            }
     
        } else{
            LoginView()
        }
        
    }
    private func toggleTabs(reflect: Bool = false, journey: Bool = false, insights: Bool = false, settings: Bool = false) {
            isReflectToggled = reflect
            isJourneyToggled = journey
            isInsightsToggled = insights
            isSettingsToggled = settings
    }
}


#Preview {
    ContentView()
}


