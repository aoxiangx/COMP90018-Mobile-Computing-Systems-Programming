//
//  PieHomeView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 22/9/2024.
//

import SwiftUI

struct PieHomeView: View {
    let percentages: [Double]
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
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
}

#Preview {
    PieHomeView(percentages: [35, 50, 65, 75, 85, 90, 55])
}
