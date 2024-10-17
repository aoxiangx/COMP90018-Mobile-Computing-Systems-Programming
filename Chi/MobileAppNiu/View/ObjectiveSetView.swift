//
//  ObjectiveSetView.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 2/10/2024.
//

import SwiftUI

// Ensure that ObjectiveSetView uses the correct ObjectiveViewModel and DailyObjectives

struct ObjectiveDetail: View {
    let type: ObjectiveViewModel.ObjectiveType
    @ObservedObject var viewModel: ObjectiveViewModel

    var body: some View {
        VStack {
            Text("Edit \(type == .sunlight ? "Daylight Time" : type == .greenArea ? "Green Space Activity Time" : "Total Activity Time")")
            Stepper("Objective: \(self.binding(for: type).wrappedValue) minutes", value: self.binding(for: type), in: 0...480)
            Button("Done") {
                viewModel.showDetail = false
            }
            .padding()
        }
        .padding()
    }
    
    private func binding(for type: ObjectiveViewModel.ObjectiveType) -> Binding<Int> {
        switch type {
        case .sunlight:
            return $viewModel.objectives.sunlightDuration
        case .greenArea:
            return $viewModel.objectives.greenAreaActivityDuration
        case .totalActivity:
            return $viewModel.objectives.totalActivityDuration
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
                ObjectiveCard(title: "Active Time", value: $viewModel.objectives.totalActivityDuration, type: .totalActivity, viewModel: viewModel)
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
}

#Preview {
    ObjectiveSetView()
}
