//
//  ObjectiveNotification.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 23/9/2024.
//

import SwiftUI

struct ObjectiveNotification: View {
    @State private var progress: Double = 0.5 // 50%
    var body: some View {
        VStack{
            Text(
                "Notice: You haven’t had enough sunlight time in the past week!"
            )
            .font(Constants.caption)
            .foregroundColor(Constants.gray3)

            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    HStack(alignment: .bottom){
                        Image("Sun_Light_Icon")
                            .resizable()
                            .padding(8)
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 4) { //Description of the Activity
                            // Body Text
                            Text("Daylight Time ")
                                .font(Font.custom("Roboto", size: 16))
                                .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                            // Secondary Section Title
                            Text("24 Min")
                                .font(Font.custom("Roboto", size: 24))
                                .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                        }
                        Spacer() // Use spacer to push the next text to the right edge (if needed)
                        Text("Objective: 40 Min")
                            .font(Font.custom("Roboto", size: 12))
                            .foregroundColor(Constants.gray3)
                    }
                   
                }
                GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle() // Background
                                    .frame(width: geometry.size.width, height: 20)
                                    .foregroundColor(.gray)
                                    .opacity(0.3)
                                    .cornerRadius(10)
                                
                                Rectangle() // Foreground representing the steps progress
                                    .frame(width: min(self.progress * geometry.size.width, geometry.size.width),height: 20)
                                    .foregroundColor(Constants.Yellow1)
                                    .animation(.linear, value: progress)
                                    .cornerRadius(10)
                            }
                        }
                .frame(height: 21)
               
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Constants.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            .overlay(
              RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.15)
                .stroke(Constants.gray4, lineWidth: 0.3)
            )
        }
    }
}

#Preview {
    ObjectiveNotification()
}
