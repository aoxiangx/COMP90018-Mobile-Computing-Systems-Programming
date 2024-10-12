//
//  ContentView 2.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 12/10/2024.
//


import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @AppStorage("log_Status") private var logStatus: Bool = true // Remember to set as false
    @State private var isReflectToggled = false
    @State private var isJourneyToggled = false
    @State private var isInsightsToggled = false
    @State private var isSettingsToggled = false

    @StateObject var healthManager = HealthManager() // Create a single instance

    var body: some View {
        if logStatus {
            TabView {
                NavigationView {
                    HomeView()
                        .environmentObject(LocationManager())
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
                    SummaryBoxesView()
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
            .environmentObject(healthManager) // Inject into the environment here
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