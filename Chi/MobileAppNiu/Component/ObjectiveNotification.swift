import SwiftUI

struct ObjectiveNotification: View {
    var currentTime: Int? // Current time (can be nil)
    var objectiveTime: Int? // User-set objective time (can be nil)
    var objectiveType: String? // Objective type, can be nil

    init(currentTime: Int? = nil, objectiveTime: Int? = nil, objectiveType: String? = nil) {
        self.currentTime = currentTime
        self.objectiveTime = objectiveTime
        self.objectiveType = objectiveType
    }

    // Determine the message based on progress
    private var progressMessage: String {
        let progress = currentTime != nil && objectiveTime != nil ? Double(currentTime!) / Double(objectiveTime!) : 0
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
    }

    // Determine the icon based on the objective type
    private var objectiveIcon: String {
        switch objectiveType {
        case "Daylight time":
            return "Sun_Light_Icon"
        case "Green Space Time":
            return "Green_Space_Icon" // You need to provide the corresponding icon name
        case "Active Index":
            return "Active_Index_Icon" // You need to provide the corresponding icon name
        default:
            return "Default_Icon" // You need to provide the default icon name
        }
    }

    // Determine the progress bar color based on the objective type
    private var progressBarColor: Color {
        switch objectiveType {
        case "Daylight time":
            return Constants.Yellow1
        case "Green Space Time":
            return Constants.Green
        case "Active Index":
            return Constants.Red
        default:
            return .gray // Default color
        }
    }

    var body: some View {
        VStack {
            if let objective = objectiveTime, let current = currentTime, let objectiveType = objectiveType {
                // Display the message and the objective based on progress
                Text(progressMessage)
                    .font(Constants.caption)
                    .foregroundColor(Constants.gray3)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        HStack(alignment: .bottom) {
                            Image(objectiveIcon) // Dynamically display the icon
                                .resizable()
                                .padding(8)
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(objectiveType.capitalized)") // Dynamically display the objective type
                                    .font(Font.custom("Roboto", size: 16))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                                Text("\(current) Min") // Display current time
                                    .font(Font.custom("Roboto", size: 24))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                                Text("per day") // Display time unit
                                    .font(Font.custom("Roboto", size: 12))
                                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                            }
                            Spacer()
                            Text("Objective: \(objective) Min") // Display the objective time
                                .font(Font.custom("Roboto", size: 12))
                                .foregroundColor(Constants.gray3)
                        }
                    }
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 20)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                                .cornerRadius(10)
                            Rectangle()
                                .frame(width: min(Double(current) / Double(objective) * geometry.size.width, geometry.size.width), height: 20)
                                .foregroundColor(progressBarColor) // Set the progress bar color dynamically
                                .animation(.linear, value: currentTime)
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
        }
    }
}
#Preview {
    // Test case with no objective set
    ObjectiveNotification()
    
    // Test case with an objective set
    ObjectiveNotification(currentTime: 20, objectiveTime: 100, objectiveType: "Daylight time")
    
    // Test case with green space objective
    ObjectiveNotification(currentTime: 45, objectiveTime: 100, objectiveType: "Green Space Time")
    
    // Test case with active index objective
    ObjectiveNotification(currentTime: 60, objectiveTime: 100, objectiveType: "Active Index")
}
