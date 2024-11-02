//
//  PieHomeView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 22/9/2024.
//

import SwiftUI

struct PieHomeView: View {
    let percentages: [Double]
    let daysOfWeek: [String]

    init(percentages: [Double]) {
        self.percentages = percentages
        self.daysOfWeek = PieHomeView.generateLast7Days() // Dynamically generate days
    }

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ForEach(0..<daysOfWeek.count, id: \.self) { index in
                    
                    PieView(percentage: percentages[index])
                        .frame(maxWidth: .infinity)
                }
            }
            HStack(spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(Constants.gray3)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(width: 361, height: 64) // Fixed view size
    }

    // Function to generate the last 7 days, starting from today
    static func generateLast7Days() -> [String] {
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E" // Short day format (Mon, Tue, etc.)

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            return dateFormatter.string(from: date)
        }.reversed() // Reverse to display from earlier to later
    }
}

#Preview {
    PieHomeView(percentages: [35, 50, 65, 75, 85, 90, 55])
}
