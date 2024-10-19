//
//  PieView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 21/9/2024.
//

import SwiftUI

struct PieView: View {
    let percentage: Double // Input percentage

    var body: some View {
        ZStack {
            Canvas { context, size in
                let total = 100.0 // Total percentage
                let startAngle: Double = 90.0 // Starting angle
                let endAngle = startAngle + (percentage / total) * 360 // Calculate ending angle

                // Create the pie chart path
                let piePath = Path { path in
                    path.move(to: CGPoint(x: size.width / 2, y: size.height / 2)) // Center point
                    path.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2),
                                radius: min(size.width, size.height) / 2,
                                startAngle: Angle(degrees: startAngle),
                                endAngle: Angle(degrees: endAngle),
                                clockwise: false)
                    path.closeSubpath()
                        // Close the path
                }
                   

                // Determine color based on percentage
                let color = colorForPercentage(percentage)

                // Fill the pie chart with the determined color
                context.fill(piePath, with: .color(color))

                // Add a border to the pie chart
                context.stroke(piePath, with: .color(Constants.gray3), lineWidth: 0.2)
            }
            .frame(width: 32, height: 32) // Size of the pie chart view
        }
    }
    
    // Determine the appropriate color based on the percentage
    func colorForPercentage(_ percentage: Double) -> Color {
        if percentage < 50 {
            let index = min(2, max(0, Int((percentage / 50.0) * 3.0)))
            return [Constants.Blue3, Constants.Blue2, Constants.Blue1][index]
        } else {
            let index = min(2, max(0, Int(((percentage - 50) / 50.0) * 3.0)))
            return [Constants.Yellow1, Constants.Yellow2, Constants.Yellow3][index]
        }
    }

}

#Preview {
    PieView(percentage: 35) // Example data
}
