//
//  ExplainationView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI

struct ExplainationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Secondary Section Title
            Text("Why You Need Sunlight?")
              .font(Font.custom("Roboto", size: 24))
              .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
              .frame(maxWidth: .infinity, alignment: .bottomLeading)
        }
        .padding(0)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
        VStack(alignment: .leading, spacing: 8) {
            // Body Text
            Text("Sunlight does more than just light up your day—it's essential for mental wellness, helping to balance and energize you. Sunlight increases serotonin, boosting mood and calmness. It also aligns sleep-wake cycles for better rest and refreshment. As a key player in vitamin D production, sunlight supports brain health and maintains high energy levels. Additionally, exposure to natural light sharpens focus and enhances cognitive function, helping you think more clearly and perform better. Embrace natural light to uplift your mental health!")
              .font(Font.custom("Roboto", size: 16))
              .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
              .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Constants.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color(red: 0.34, green: 0.35, blue: 0.35), lineWidth: 0.3)
        )
        
    }
}

#Preview {
    ExplainationView()
}
