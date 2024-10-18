import SwiftUI

struct ObjectiveDetail: View {
    let type: ObjectiveViewModel.ObjectiveType
    @ObservedObject var viewModel: ObjectiveViewModel

    // State variable to hold the input text
    @State private var inputValue: String = ""

    var body: some View {
        VStack {
            Text("Enter your objective for \n \(title(for: type))")
            .font(.headline)
            .multilineTextAlignment(.center) // Center the text
            .padding()

            // HStack for TextField and Stepper
                        HStack(spacing: 0) { // Set spacing to 0 for no space between elements
                            // TextField for direct input
                            TextField("", text: $inputValue)
                                .keyboardType(.numberPad) // Show the numeric keyboard
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: dynamicWidth(for: inputValue)) // Adjust width based on input
                                .onAppear {
                                    // Set initial input value to the current objective value
                                    inputValue = "\(self.binding(for: type).wrappedValue)"
                                }
                                .onChange(of: inputValue) { newValue in
                                                        if type == .stepCount {
                                                            // Limit for Active Index (step count) is 0 to 50000
                                                            if let intValue = Int(newValue), intValue >= 0, intValue <= 50000 {
                                                                self.binding(for: type).wrappedValue = intValue
                                                            } else if newValue.isEmpty {
                                                                self.binding(for: type).wrappedValue = 0 // Reset to 0 if input is empty
                                                            }
                                                        } else {
                                                            // Limit for other objectives is 0 to 480
                                                            if let intValue = Int(newValue), intValue >= 0, intValue <= 480 {
                                                                self.binding(for: type).wrappedValue = intValue
                                                            } else if newValue.isEmpty {
                                                                self.binding(for: type).wrappedValue = 0 // Reset to 0 if input is empty
                                                            }
                                                        }
                                                    }
                                                    .fixedSize(horizontal: true, vertical: false) // Prevent width growth

                            // Stepper for adjusting the objective
                            Stepper("", value: self.binding(for: type), in: 0...480)
                                .onChange(of: self.binding(for: type).wrappedValue) { newValue in
                                    inputValue = "\(newValue)" // Update inputValue when Stepper changes
                                }
                                .padding(.leading, 8) // Optional padding for a slight separation from the TextField
                        }
                        .frame(maxWidth: .infinity, alignment: .center) // Center the HStack
                        .padding(.horizontal)
            


            Button("Done") {
                viewModel.showDetail = false
            }
            .padding()
        }
        .padding()
        .onAppear {
            // Ensure the inputValue is synced with the current objective value
            inputValue = "\(self.binding(for: type).wrappedValue)"
        }
    }

    // Helper function to get the title based on type
    private func title(for type: ObjectiveViewModel.ObjectiveType) -> String {
        switch type {
        case .sunlight: return "Daylight Time"
        case .greenArea: return "Green Space Activity Time"
        case .stepCount: return "Step Count"
        // Add more cases as necessary
        default: return "Unknown Objective"
        }
    }
    // Function to dynamically calculate the width of the TextField based on the input value
    private func dynamicWidth(for input: String) -> CGFloat {
        let baseWidth: CGFloat = 40 // Minimum width
        let additionalWidth: CGFloat = 15 // Width per character
        let width = baseWidth + (CGFloat(input.count) * additionalWidth)
        return min(width, 150) // Cap the maximum width if necessary
    }
    private func binding(for type: ObjectiveViewModel.ObjectiveType) -> Binding<Int> {
        switch type {
        case .sunlight:
            return $viewModel.objectives.sunlightDuration
        case .greenArea:
            return $viewModel.objectives.greenAreaActivityDuration
        case .stepCount:
            return $viewModel.objectives.stepCount
        // Add more cases as necessary
        default:
            return Binding.constant(0) // Default binding for unhandled cases
        }
    }
}

struct ObjectiveCard: View {
    let title: String
    @Binding var value: Int
    let type: ObjectiveViewModel.ObjectiveType
    @ObservedObject var viewModel: ObjectiveViewModel

    var body: some View {
        Button(action: {
            viewModel.editObjective(type)
        }) {
            VStack {
                Text(title)
                    .font(.headline)
                Text("\(value) Minutes")
                    .font(.title)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct ObjectiveSetView: View {
    @StateObject var viewModel = ObjectiveViewModel()  // Reference to ObjectiveViewModel from the Model folder

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ObjectiveCard(title: "Daylight Time", value: $viewModel.objectives.sunlightDuration, type: .sunlight, viewModel: viewModel)
                ObjectiveCard(title: "Green Space Time", value: $viewModel.objectives.greenAreaActivityDuration, type: .greenArea, viewModel: viewModel)
                ObjectiveCard(title: "Active Index", value: $viewModel.objectives.stepCount, type: .stepCount, viewModel: viewModel)
            }
            .padding()
            .navigationTitle("Set Your Objectives")
        }
        .sheet(isPresented: $viewModel.showDetail) {
            if let type = viewModel.activeCard {
                ObjectiveDetail(type: type, viewModel: viewModel)
            }
        }
    }
    
    // Function to define the stepper range for each objective type
    private func stepperRange(for type: ObjectiveViewModel.ObjectiveType) -> ClosedRange<Int> {
        switch type {
        case .stepCount:
            return 0...50000 // Limit for step count
        default:
            return 0...480 // Limit for other objectives
        }
    }
}

#Preview {
    ObjectiveSetView()
}
