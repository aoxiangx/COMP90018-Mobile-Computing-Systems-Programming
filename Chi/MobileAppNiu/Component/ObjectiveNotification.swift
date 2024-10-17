import SwiftUI

struct ObjectiveNotification: View {
    @EnvironmentObject var healthManager: HealthManager
    var activity: Activity?
    // Computed property to return the latest objective time
    private var objectiveTime: Int {
        switch activity {
        case .daylight:
            return viewModel.objectives.sunlightDuration
        case .hrv:
            return viewModel.objectives.greenAreaActivityDuration
        case .steps:
            return viewModel.objectives.stepCount
        default:
            return 0
        }
    }
     // User-set objective time (can be nil)
    var objectiveType: String? // Objective type, can be nil
    @StateObject private var viewModel = ObjectiveViewModel() // StateObject instantiated here
    @State private var currentTime: Double = 0.0
    @State private var objectiveDataActivity: ObjectiveData? // Using Optional, since it might be set later
        
    // Determine the message based on progress
    private var progressMessage: String {
        // Ensure that `objectiveTime` is greater than 0 to avoid division by zero
        if  objectiveTime > 0 {
            let progress = currentTime / Double(objectiveTime)

            switch progress {
            case ..<0.25:
                return "Just starting—let’s keep going!"
            case 0.25..<0.5:
                return "Nice progress, keep it up!"
            case 0.5..<0.75:
                return "You're doing great, almost there!"
            case 1.0...:
                return "Awesome job—you did it!"
            default:
                return "Stay focused and keep tracking!"
            }
        } else {
            return "Stay focused and keep tracking!"
        }
    }

    var body: some View {
        VStack {
            if activity != nil
            {
                let objectiveDataActivity = activity!.objectiveInfo(viewModel: viewModel) // Assuming this is not optional
                
                // Display the message and the objective based on progress
                Text(progressMessage)
                    .font(Constants.caption)
                    .foregroundColor(Constants.gray3)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        HStack(alignment: .bottom) {
                            Image(objectiveDataActivity.icon ?? .activeIndexIcon) // Dynamically display the icon
                                .resizable()
                                .padding(8)
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(objectiveDataActivity.title) // Dynamically display the objective type
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                                Text("\(Int(currentTime)) \(objectiveDataActivity.subtitle)") // Display current time
                                    .font(Font.custom("Roboto", size: 24))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                                Text("per day") // Display time unit
                                    .font(Font.custom("Roboto", size: 12))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                            }
                            Spacer()
                            Text("Objective: \(objectiveTime ?? 0) \(objectiveDataActivity.subtitle)") // Display the objective time
                                .font(Font.custom("Roboto", size: 12))
                                .foregroundColor(Constants.gray3)
                        }
                    }
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background bar
                            Rectangle()
                                .frame(width: geometry.size.width, height: 20)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                                .cornerRadius(10)

                            // Foreground progress bar
                            Rectangle()
                                .frame(
                                    width: min((currentTime / Double(objectiveDataActivity.objectiveTime ?? 1)) * geometry.size.width, geometry.size.width),
                                    height: 20
                                )
                                .foregroundColor(objectiveDataActivity.color) // Use dynamic color based on activity type
                                .animation(.linear, value: currentTime) // Animate the progress change
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 21)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(Constants.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.15)
                        .stroke(Constants.gray4, lineWidth: 0.3)
                )
            } else {
                // Case where no objective is set, keep the background and frame
                VStack(alignment: .center, spacing: 8) {
                    Text("Press the button to set your first objective!")
                        .font(Constants.caption)
                        .foregroundColor(Constants.gray3)
                        .padding()

                    NavigationLink(destination: ObjectiveSetView()) {
                        Text("Set Objective")
                            .font(Font.custom("Roboto", size: 16))
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Constants.white) // Keep consistent background
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 0.15)
                        .stroke(Constants.gray4, lineWidth: 0.3) // Keep consistent outer frame
                )
            }
        }.onAppear {
            let latestObjectives = UserDefaults.standard.getDailyObjectives(forKey: "UserObjectives")
                if let loadedObjectives = latestObjectives {
                    viewModel.objectives = loadedObjectives
            }
            fetchTodayValue() // Fetch today's step value when the view appears
        }
    }
    
    private func fetchTodayValue() {
        activity?.dayValue(using: healthManager) { (value, error) in
            if let error = error {
                print("Error fetching step value: \(error.localizedDescription)")
            } else if let steps = value {
                DispatchQueue.main.async {
                    self.currentTime = steps // Update the currentTime state variable
                }
            }
        }
    }
}

#Preview {
    // Test case with no objective set
    ObjectiveNotification()
    ObjectiveNotification(activity: .steps).environmentObject(HealthManager())
}
