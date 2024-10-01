//
//  BackgroundView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 21/9/2024.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(hex: "FFF8C9"), location: 0.0),  // Start with FFF8C9
                .init(color: Color(hex: "EDF5FF"), location: 0.6)   // End with EDF5FF
            ]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)  // To fill the entire screen
    }
}

#Preview {
    BackgroundView()
}
