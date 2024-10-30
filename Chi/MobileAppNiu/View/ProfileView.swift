//
//  ProfileView.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 1/10/2024.
//

import SwiftUI
import UserNotifications

struct ProfileView: View {
    @AppStorage("log_Status") private var logStatus: Bool = true
    @State private var isNotificationsEnabled = false
    @State private var hasCheckedInitialState = false
    @State private var showingSettingsAlert = false
    @Environment(\.scenePhase) private var scenePhase
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationsEnabled = settings.authorizationStatus == .authorized
                hasCheckedInitialState = true
            }
        }
    }
    
    func toggleNotifications() {
        if isNotificationsEnabled {
            // Show confirmation alert before directing to Settings
            showingSettingsAlert = true
        } else {
            // Request notification permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                DispatchQueue.main.async {
                    isNotificationsEnabled = granted
                    if !granted {
                        print("Notification permission denied")
                    }
                }
            }
        }
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                            .foregroundColor(Constants.gray2)
                    }
                    .padding(.bottom, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Personal Information Section
                        Text("Personal Information")
                            .font(Constants.body)
                            .foregroundColor(Constants.gray2)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            // About You Button
                            HStack(alignment: .center) {
                                Text("About You")
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Constants.white)
                            .cornerRadius(12)
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.3)
                                    .foregroundColor(Color.gray),
                                alignment: .bottom
                            )
                            
                            // Your Objectives Link
                            NavigationLink(destination: ObjectiveSetView()) {
                                HStack(alignment: .center) {
                                    Text("Your Objectives")
                                        .font(Font.custom("Roboto", size: 16))
                                        .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Constants.white)
                                .cornerRadius(12)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.3)
                                        .foregroundColor(Color.gray),
                                    alignment: .bottom
                                )
                            }
                            
                            // About You (Second Instance)
                            HStack(alignment: .center) {
                                Text("About You")
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Constants.white)
                            .cornerRadius(12)
                        }
                        .padding(0)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: -0.2)
                                .stroke(Constants.gray4, lineWidth: 0.4)
                        )
                        .padding(.bottom, 8)
                        
                        // App Preference Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("App Preference")
                                .font(Constants.body)
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            
                            HStack(alignment: .center) {
                                Text("System Notification")
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                                Spacer()
                                Toggle("", isOn: $isNotificationsEnabled)
                                    .labelsHidden()
                                    .tint(Constants.Yellow1)
                                    .onChange(of: isNotificationsEnabled) { newValue in
                                        if hasCheckedInitialState {
                                            toggleNotifications()
                                        }
                                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Constants.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: -0.2)
                                    .stroke(Constants.gray4, lineWidth: 0.4)
                            )
                        }
                        
                        // Logout Button
                        Button(action: {
                            logStatus = false
                        }) {
                            Text("Logout")
                                .font(Constants.body)
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Constants.Yellow1)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                    .padding(0)
                    .frame(width: 361, alignment: .topLeading)
                }
                .padding(.top, 23)
                .padding(16)
            }
        }
        .onAppear {
            checkNotificationStatus()
        }
        // Monitor scene phase changes
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkNotificationStatus()
            }
        }
        // Add confirmation alert
        .alert("Notification Settings", isPresented: $showingSettingsAlert) {
            Button("Cancel") {
                // Restore toggle state on cancel
                isNotificationsEnabled = true
            }
            Button("Open Settings") {
                openSettings()
            }
        } message: {
            Text("You need to modify notification permissions in System Settings. Would you like to open Settings?")
        }
    }
}

// Preview Provider
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
