//
//  ExplainationView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI

struct ExplainationView: View {
    var body: some View {
        VStack {
            Text("Why You Need Sunlight?")
            .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.vertical) {
                Text("Sunlight does more than just light up your day—it's essential for mental wellness, helping to balance and energize you. Sunlight increases serotonin, boosting mood and calmness. It also aligns sleep-wake cycles for better rest and refreshment. As a key player in vitamin D production, sunlight supports brain health and maintains high energy levels. Additionally, exposure to natural light sharpens focus and enhances cognitive function, helping you think more clearly and perform better. Embrace natural light to uplift your mental health!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    ExplainationView()
}
