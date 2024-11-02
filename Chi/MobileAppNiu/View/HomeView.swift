import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthManager
//    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var objectiveViewModel = ObjectiveViewModel()
    @EnvironmentObject var sharedDataModel: SharedData // Use SharedDataModel
    @State  var score: Double
    @AppStorage("log_Status") private var logStatus: Bool = false
    @State private var currentPageIndex = 0
    
    // State variables for percentages and loading state
    @State private var percentages: [Double] = Array(repeating: 0.0, count: 7)
    @State private var loading: Bool = true
    @State private var objectiveNotifications: [ObjectiveNotification] = []
//    var objectiveNotifications: [ObjectiveNotification] {
//        var notifications: [ObjectiveNotification] = []
//        
//        if objectiveViewModel.objectives.sunlightDuration >= 0 {
//            notifications.append(
//                ObjectiveNotification(
//                    activity: .daylight
//                )
//            )
//        }
//        
//        if objectiveViewModel.objectives.greenAreaActivityDuration >= 0 {
//            notifications.append(
//                ObjectiveNotification(
//                    activity: .green
//                )
//            )
//        }
//        
//        if objectiveViewModel.objectives.stepCount >= 0 {
//            notifications.append(
//                ObjectiveNotification(
//                    activity: .steps
//                )
//            )
//        }
//        
//        // If no objectives are set, show default notification
//        if notifications.isEmpty {
//            notifications.append(ObjectiveNotification())
//        }
//        
//        return notifications
//    }
    
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
                            
                            CircleChartView(score: score)
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
                    .refreshable {
                        refreshData()
                    }
                }
            }
        }
        .onAppear {
            fetchAndCalculatePercentages()
            refreshNotifications()
        }
    }
    private func refreshData() {
            loading = true
            fetchAndCalculatePercentages()
            refreshNotifications()
    }
    private func refreshNotifications() {
            var notifications: [ObjectiveNotification] = []
            
            if objectiveViewModel.objectives.sunlightDuration >= 0 {
                notifications.append(ObjectiveNotification(activity: .daylight))
            }
            
            if objectiveViewModel.objectives.greenAreaActivityDuration >= 0 {
                notifications.append(ObjectiveNotification(activity: .green))
            }
            
            if objectiveViewModel.objectives.stepCount >= 0 {
                notifications.append(ObjectiveNotification(activity: .steps))
            }
            
            if notifications.isEmpty {
                notifications.append(ObjectiveNotification())
            }
            
            objectiveNotifications = notifications
        }
    private func fetchAndCalculatePercentages() {
        
        let group = DispatchGroup()
        var steps: [Double] = []
        var daylight: [Double] = []
        
        // Fetch last 7 days steps
        group.enter()
        healthManager.fetchLast7DaysSteps { fetchedSteps in
            steps = fetchedSteps.map { $0.1 }
            group.leave()
        }
        
        // Fetch last 7 days daylight
        group.enter()
        healthManager.fetchLast7DaysDaylight { fetchedDaylight in
            daylight = fetchedDaylight.map { $0.1 }
            group.leave()
        }
        
        // Once both steps and daylight are fetched
        group.notify(queue: .main) {
            let greenSpace = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0] // Example green space data
            
            // Retrieve user objectives
            
            @StateObject var objectiveViewModel = ObjectiveViewModel()
            let objectives = objectiveViewModel.objectives
            
            var newPercentages: [Double] = []
            
            // Loop through each day and fetch scores
            for day in 0..<7 {
                // Create a semaphore for each day's fetch
                let semaphore = DispatchSemaphore(value: 0)
                var percentage = 0.0
                var dailyScore = 0.0
                
                // Fetch sleep data
                healthManager.fetchSleepOnDay(day) { sleepHours, error in
                    if let sleepHours = sleepHours {
                        let sleepScore = min((sleepHours / 7.0) * 18.0, 50.0 / 3.0) // Cap to max of ~16.67
                        dailyScore += sleepScore
                        print("Sleep dailyScore: \(dailyScore), sleepHours: \(sleepScore)")
                    }
                    semaphore.signal() // Signal that sleep data is done
                }
                
                // Fetch HRV data
                healthManager.fetchHRVOnDay(day) { hrvValue, error in
                    if let hrvValue = hrvValue {
                        let stressScore: Double
                        if hrvValue <= 20 {
                            stressScore = 5.0
                        } else if hrvValue <= 40 {
                            stressScore = 15.0
                        } else {
                            stressScore = 20.0
                        }
                        dailyScore += min(stressScore, 50.0 / 3.0) // Cap to max of ~16.67
                        print("HRV stressScore: \(stressScore), dailyScore: \(dailyScore)")
                    }
                    semaphore.signal() // Signal that HRV data is done
                }
                
                // Fetch noise levels
                healthManager.fetchNoiseLevelsOnDay(day) { noiseLevel, error in
                    if let noiseLevel = noiseLevel {
                        let noiseScore: Double
                        if noiseLevel < 50 {
                            noiseScore = 17.0
                        } else if noiseLevel < 60 {
                            noiseScore = 10.0
                        } else if noiseLevel < 70 {
                            noiseScore = 7.0
                        } else {
                            noiseScore = 0.0
                        }
                        dailyScore += min(noiseScore, 50.0 / 3.0) // Cap to max of ~16.67
                        print("NoiseScore: \(noiseScore), dailyScore: \(dailyScore)")
                    }
                    semaphore.signal() // Signal that noise data is done
                }
                
                // Wait until all data is fetched
                _ = semaphore.wait(timeout: .distantFuture)
                
                // Calculate the percentage after all data is fetched
                let green = min(greenSpace[day] / Double(objectives.greenAreaActivityDuration), 1.0) * (50.0 / 3.0)
                let sunlight = min(daylight[day] / Double(objectives.sunlightDuration), 1.0) * (50.0 / 3.0)
                let stepCount = min(steps[day] / Double(objectives.stepCount), 1.0) * (50.0 / 3.0)
                print("stepcountObjective: \(Double(objectives.stepCount))")
                // Check for NaN and set to 0 if needed
                let safeGreen = green.isNaN ? 0.0 : green
                let safeSunlight = sunlight.isNaN ? 0.0 : sunlight
                let safeStepCount = stepCount.isNaN ? 0.0 : stepCount
                
                percentage = (safeGreen + safeSunlight + safeStepCount) + dailyScore
                print("Day \(day): safeGreen: \(safeGreen), safeSunlight: \(safeSunlight), safeStepCount: \(safeStepCount), percentage: \(percentage)")
                if(day == 6){
                    score = percentage
                    print("score: \(score)")
                }
                // Append percentage to the results
                newPercentages.append(Double(percentage))
            }
            
            // Update the state with calculated percentages
            self.percentages = newPercentages
            self.sharedDataModel.percentages = newPercentages
            self.loading = false
        }
    }
    
}


struct HomeViewPreview: View {
    @State private var score: Double = 66.9
    
    var body: some View {
        HomeView(score: score)
            .environmentObject(HealthManager())
//            .environmentObject(LocationManager.shared)
    }
}

#Preview {
    HomeViewPreview()
}
