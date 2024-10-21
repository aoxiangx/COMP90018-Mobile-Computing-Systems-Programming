//
//  ExplainationView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI

struct ExplainationView: View {
    var activity: Activity
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Secondary Section Title
            Text("Why You Need \(activity.title)")
              .font(Font.custom("Roboto", size: 24))
              .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
              .frame(maxWidth: .infinity, alignment: .bottomLeading)
        }
        .padding(0)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
        VStack(alignment: .leading, spacing: 8) {
            // Body Text
            Text("\(activity.reason)")
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
    ExplainationView(activity:.daylight)
}
