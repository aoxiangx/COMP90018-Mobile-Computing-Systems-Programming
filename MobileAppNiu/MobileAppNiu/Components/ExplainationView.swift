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
            Text("Why You Need Sunlight?").font(.system(size: 24))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom,8)
            ScrollView(.vertical) {
                Text("Sunlight does more than just light up your day—it's essential for mental wellness, helping to balance and energize you. Sunlight increases serotonin, boosting mood and calmness. It also aligns sleep-wake cycles for better rest and refreshment. As a key player in vitamin D production, sunlight supports brain health and maintains high energy levels. Additionally, exposure to natural light sharpens focus and enhances cognitive function, helping you think more clearly and perform better. Embrace natural light to uplift your mental health!")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(16)
                    .frame(maxWidth: .infinity,alignment: .leading)
                
            }.frame(maxHeight: 200)
            .overlay(
                RoundedRectangle(cornerRadius: 12) // Adjust the corner radius if needed
                    .stroke(Color.gray, lineWidth: 1) // Border color and width
            )
        }
    }
}

#Preview {
    ExplainationView()
}
