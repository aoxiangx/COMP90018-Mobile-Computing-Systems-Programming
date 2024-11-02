import SwiftUI
import UserNotifications

struct ProfileView: View {
    @AppStorage("log_Status") private var logStatus: Bool = true
    @State private var isNotificationsEnabled = false
    @State private var showingSettingsAlert = false
    @Environment(\.scenePhase) private var scenePhase
    
    // Check the current notification authorization status
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Handle notification toggle action
    func handleNotificationToggle(newValue: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    // If currently authorized and user wants to turn off
                    if !newValue {
                        showingSettingsAlert = true
                        isNotificationsEnabled = true  // Keep the toggle on
                    }
                case .denied:
                    // If previously denied and user wants to turn on
                    if newValue {
                        showingSettingsAlert = true
                        isNotificationsEnabled = false  // Keep the toggle off
                    }
                case .notDetermined:
                    // First time request
                    requestNotificationPermission()
                default:
                    break
                }
            }
        }
    }
    
    // Request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                isNotificationsEnabled = granted
                if !granted {
                    print("Notification permission denied")
                }
            }
        }
    }
    
    // Open system settings
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
                    // Header
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
                        
                        // Objectives Section
                        VStack(alignment: .leading, spacing: 0) {
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
                            }
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
                        
                        // App Preferences Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("App Preference")
                                .font(Constants.body)
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            
                            // Notification Toggle
                            HStack(alignment: .center) {
                                Text("System Notification")
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                                Spacer()
                                Toggle("", isOn: $isNotificationsEnabled)
                                    .labelsHidden()
                                    .tint(Constants.Yellow1)
                                    .onChange(of: isNotificationsEnabled) { newValue in
                                        handleNotificationToggle(newValue: newValue)
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
        // View lifecycle and state management
        .onAppear {
            checkNotificationStatus()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkNotificationStatus()
            }
        }
        // Settings alert
        .alert("Notification Settings", isPresented: $showingSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                openSettings()
            }
        } message: {
            Text("You need to modify notification permissions in System Settings. Would you like to open Settings?")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
