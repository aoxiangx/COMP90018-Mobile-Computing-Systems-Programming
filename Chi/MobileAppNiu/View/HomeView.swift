import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    
    
    @EnvironmentObject var manager : HealthManager
    
    @EnvironmentObject var locationManager: LocationManager
//    var locationManager = LocationManager.shared
    
    @State private var score: Double = 34.0
    
    
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    // Import ObjectiveViewModel
    @StateObject private var objectiveViewModel = ObjectiveViewModel()
    
    @State private var currentPageIndex = 0
    var objectiveNotifications: [ObjectiveNotification] {
        var notifications: [ObjectiveNotification] = []
        
        if objectiveViewModel.objectives.sunlightDuration > 0 {
            notifications.append(
                ObjectiveNotification(
                    activity: .daylight
                )
            )
        }
        
        if objectiveViewModel.objectives.greenAreaActivityDuration > 0 {
            notifications.append(
                ObjectiveNotification(
                    activity: .hrv
                )
            )
        }
        
        if objectiveViewModel.objectives.stepCount > 0 {
            notifications.append(
                ObjectiveNotification(
                    activity: .steps
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
            ZStack{
                
                // Background
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFF8C9"), location: 0.0),  // Start with FFF8C9
                    .init(color: Color(hex: "EDF5FF"), location: 0.6)   // End with EDF5FF
                ]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)  // To fill the entire screen
                
                // start scroll view
                ScrollView {
                    
                    VStack {
                        
                        // start Ztack
                        ZStack (alignment: .topLeading){
                            
                            // start Vstack
                            VStack(alignment: .leading) {
                                // Date view
                                DateHomeView()
                                
                                PieHomeView(percentages: [35, 50, 65, 75, 85, 90, 55]).padding(.leading, 15)
                               
                                CircleChartView(score: $score)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .multilineTextAlignment(.center)
//                                LocationView()
                                
                                // TabView for sliding list of notifications
                                    TabView(selection: $currentPageIndex) {
                                        ForEach(0..<objectiveNotifications.count, id: \.self) { index in
                                            objectiveNotifications[index]
                                                .tag(index)
                                        }
                                    }
                                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                    .frame(height: 150)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    // Display page indicator if there are objectives set
                                    if objectiveNotifications.count > 1 {
                                        HStack {
                                            ForEach(0..<objectiveNotifications.count, id: \.self) { index in
                                                Circle()
                                                    .fill(currentPageIndex == index ? Color.blue : Color.gray)
                                                    .frame(width: 8, height: 8)
                                            }
                                        }
                                         // Adjust location of indicator
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                // end Vstack list of notifications
                                
                                
                                SummaryBoxesView()
                                LocationView()
                            // end Vstack
                            }
                            
                        // end Ztack
                        }
                        
                    }
                
                // end scroll view
                }
            }
        }
}

#Preview {
    HomeView()
        .environmentObject(HealthManager())
        .environmentObject(LocationManager.shared)
}
