//
//  ContentView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//
import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @AppStorage("log_Status") private var logStatus: Bool = false // Remember to set as false
    @State private var isReflectToggled = false
    @State private var isJourneyToggled = false
    @State private var isInsightsToggled = false
    @State private var isSettingsToggled = false
    @State private var score: Double = 0.0
    @State private var averageScore : Double = 0.0
    @EnvironmentObject var healthManager: HealthManager

    var body: some View {
        if logStatus {
            TabView {
                NavigationView {
                    
                    HomeView(score: score)
                        .navigationBarHidden(true)
                        .environmentObject(healthManager)
                        .environmentObject(LocationManager.shared)
                }
                .tabItem {
                    Image(isReflectToggled ? .mindfulnessToggled : .mindfulUntoggled)
                    Text("Reflect")
                }
                .onAppear {
                    toggleTabs(reflect: true)
                }

                NavigationView {
                    JourneyView()
                }
                .tabItem {
                    Image(isJourneyToggled ? .journeyToggled : .journeyUntoggled)
                    Text("Journey")
                }
                .onAppear {
                    toggleTabs(journey: true)
                }

                NavigationView {
                    Insights().environmentObject(healthManager)
                         //Inject HealthManager to let child see the health
                }
                .tabItem {
                    Image(isInsightsToggled ? .insightsToggled : .insightsUntoggled)
                    Text("Insights")
                }
                .onAppear {
                    toggleTabs(insights: true)
                }

                NavigationView {
                    ProfileView()
                }
                .tabItem {
                    Image(isSettingsToggled ? .settingToggled : .settingUntoggled)
                    Text("Setting")
                }
                .onAppear {
                    toggleTabs(settings: true)
                }
            }
             // Inject into the environment here
        } else {
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
