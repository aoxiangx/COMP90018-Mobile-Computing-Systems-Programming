import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    
    
    @EnvironmentObject var manager : HealthManager
    @EnvironmentObject var locationManager: LocationManager
    
    
    
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    // Import ObjectiveViewModel
    @StateObject private var objectiveViewModel = ObjectiveViewModel()
    
    @State private var currentPageIndex = 0
    var objectiveNotifications: [ObjectiveNotification] {
        var notifications: [ObjectiveNotification] = []
        
        if objectiveViewModel.objectives.sunlightDuration > 0 {
            notifications.append(
                ObjectiveNotification(
                    currentTime: 5,
                    objectiveTime: objectiveViewModel.objectives.sunlightDuration,
                    objectiveType: "Daylight time"
                )
            )
        }
        
        if objectiveViewModel.objectives.greenAreaActivityDuration > 0 {
            notifications.append(
                ObjectiveNotification(
                    currentTime: 45,
                    objectiveTime: objectiveViewModel.objectives.greenAreaActivityDuration,
                    objectiveType: "Green Space Time"
                )
            )
        }
        
        if objectiveViewModel.objectives.totalActivityDuration > 0 {
            notifications.append(
                ObjectiveNotification(
                    currentTime: 80,
                    objectiveTime: objectiveViewModel.objectives.totalActivityDuration,
                    objectiveType: "Active Index"
                )
            )
        }
        
        // If no objectives are set, show default notification
        if notifications.isEmpty {
            notifications.append(ObjectiveNotification())
        }
        
        return notifications
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack (alignment: .topLeading){
                    // Background
                    LinearGradient(gradient: Gradient(stops: [
                        .init(color: Color(hex: "FFF8C9"), location: 0.0),
                        .init(color: Color(hex: "EDF5FF"), location: 0.6)
                    ]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)  // Fill the screen
                    
                    VStack(alignment: .leading) {
                        // Date view
                        DateHomeView()
                        
                        PieHomeView(percentages: [35, 50, 65, 75, 85, 90, 55]).padding(.leading, 15)
                        
                        // Fetch Steps button
                        Button("Fetch Steps") {
                            manager.fetchTodaySteps()
                        }
                        .padding(.leading, 15)
                        
                        // show location
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Divider()
                                .padding(.vertical, 10)
                            
                            
                            Text("Your Current Location")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            HStack {
                                Text("Latitude:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(String(format: "%.5f", locationManager.location?.coordinate.latitude ?? 0.0))
                                    .font(.body)
                            }
                            
                            HStack {
                                Text("Longitude:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(String(format: "%.5f", locationManager.location?.coordinate.longitude ?? 0.0))
                                    .font(.body)
                            }
                            
                            Divider()
                                .padding(.vertical, 10)
                            
                            Text("Place Description:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(locationManager.locationDescription)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 5)
                            
                            Divider()
                                .padding(.vertical, 10)
                        }
                        
                        
                        ScoreEmojiView(score: 45)
                        
                        // TabView for sliding list of notifications
                        VStack {
                            TabView(selection: $currentPageIndex) {
                                ForEach(0..<objectiveNotifications.count, id: \.self) { index in
                                    objectiveNotifications[index]
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: 300)
                            
                            // Display page indicator if there are objectives set
                            if objectiveNotifications.count > 1 {
                                HStack {
                                    ForEach(0..<objectiveNotifications.count, id: \.self) { index in
                                        Circle()
                                            .fill(currentPageIndex == index ? Color.blue : Color.gray)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .padding(.top, -70)  // Adjust location of indicator
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(HealthManager())
        .environmentObject(LocationManager())
}
