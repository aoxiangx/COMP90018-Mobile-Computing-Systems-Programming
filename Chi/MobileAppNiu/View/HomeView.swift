import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthManager
//    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var objectiveViewModel = ObjectiveViewModel()
    
    @Binding var score: Double
    @AppStorage("log_Status") private var logStatus: Bool = false
    @State private var currentPageIndex = 0
    
    // State variables for percentages and loading state
    @State private var percentages: [Double] = Array(repeating: 0.0, count: 7)
    @State private var loading: Bool = true
    
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
                    activity: .green
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
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(hex: "FFF8C9"), location: 0.0),  // Start with FFF8C9
                .init(color: Color(hex: "EDF5FF"), location: 0.6)   // End with EDF5FF
            ]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)  // To fill the entire screen
            
            // Start ScrollView
            ScrollView {
                VStack {
                    // ZStack for overlapping views
                    ZStack (alignment: .topLeading) {
                        VStack(alignment: .leading) {
                            // Date view
                            DateHomeView()
                            
                            // Conditional PieHomeView based on loading state
                            if !loading {
                                PieHomeView(percentages: percentages)
                                    .padding(.leading, 15)
                            } else {
                                ProgressView()
                                    .padding(.leading, 15)
                            }
                            
                            CircleChartView(score: $score)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .multilineTextAlignment(.center)
                            
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
                            
                            // Display page indicator if there are multiple notifications
                            if objectiveNotifications.count > 1 {
                                HStack {
                                    ForEach(0..<objectiveNotifications.count, id: \.self) { index in
                                        Circle()
                                            .fill(currentPageIndex == index ? Color.blue : Color.gray)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            
                            // Dynamically change SuggestionsCapsules based on index
                            switch currentPageIndex {
                            case 0:
                                SuggestionsCapsules(activity: .daylight)
                                    .padding(.leading)
                                    .padding(.top)
                            case 1:
                                SuggestionsCapsules(activity: .green)
                                    .padding(.leading)
                                    .padding(.top)
                            case 2:
                                SuggestionsCapsules(activity: .steps)
                                    .padding(.leading)
                                    .padding(.top)
                            default:
                                SuggestionsCapsules(activity: .daylight)
                                    .padding(.leading)
                                    .padding(.top)// Default activity in case index is out of expected range
                            }
                                                        
                              
                            SummaryBoxesView(period: .day)
//                            LocationView()
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchAndCalculatePercentages()
        }
    }
    
    // Fetches health and green space data for the last 7 days, calculates percentages, and updates the state.
    private func fetchAndCalculatePercentages() {
        let group = DispatchGroup()
        var steps: [Double] = []
        var daylight: [Double] = []
        
        // Fetch last 7 days steps
        group.enter()
        healthManager.fetchLast7DaysSteps { fetchedSteps in
            steps = fetchedSteps.map { $0.1 }
            print("7days steps: \(steps)")
            group.leave()
        }
        
        // Fetch last 7 days daylight
        group.enter()
        healthManager.fetchLast7DaysDaylight { fetchedDaylight in
            daylight = fetchedDaylight.map { $0.1 }
            print("7days daylight: \(daylight)")
            group.leave()
        }
        
        // Once both steps and daylight are fetched
        group.notify(queue: .main) {
            // Fetch green space times for last 7 days
            
//            let greenSpace = locationManager.getGreenSpaceTimes(forLastNDays: 7)
            let greenSpace = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
            
            // Retrieve user objectives
            let objectives = self.objectiveViewModel.objectives
            
            var newPercentages: [Double] = []
            for day in 0..<7 {
                let green = min(greenSpace[day] / Double(objectives.greenAreaActivityDuration), 1.0)
                let sunlight = min(daylight[day] / Double(objectives.sunlightDuration), 1.0)
                let stepCount = min(steps[day] / Double(objectives.stepCount), 1.0)
                
                print("green \(green), sunlight \(sunlight), stepCount \(stepCount)")
                // Correctly grouping the addition
                let percentage = (green + sunlight + stepCount) / 3.0 * 100.0
                if(day == 6 ){
                    score = Double(percentage)
    
                }
                newPercentages.append(Double(Int(percentage))) // Take integer part
            }
            
            // Update the state with calculated percentages
            self.percentages = newPercentages
            self.loading = false
        }
    }
}


//#Preview {
//    HomeView(score: 66.9)
//        .environmentObject(HealthManager())
//        .environmentObject(LocationManager.shared)
//}

struct HomeViewPreview: View {
    @State private var score: Double = 66.9
    
    var body: some View {
        HomeView(score: $score)
            .environmentObject(HealthManager())
//            .environmentObject(LocationManager.shared)
    }
}

#Preview {
    HomeViewPreview()
}
