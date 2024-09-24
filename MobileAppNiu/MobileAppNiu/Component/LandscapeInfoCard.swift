//
//  Landscape Info Card.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 16/9/2024.
//

import SwiftUI


struct LandscapeInfoCard: View {
    var activity: String
    var iconName: ImageResource
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 4) {
                    Image(iconName)
                        .frame(width: 16, height: 16)
                    Text(activity)
                        .font(Font.custom("Roboto", size: 16))
                        .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                        .frame(maxWidth:.infinity,alignment: .leading)
                    
                }
                .padding(.vertical, 3)
                  
                Text("24 Min")
                    .font(Font.custom("Roboto", size: 24))
                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                
                Text("Past 7 Days")
                    .font(Font.custom("Roboto", size: 12))
                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // Maintain spacing for text
            
            VStack(spacing: 0) {  // Reduced spacing inside VStack containing SmallGraph
                SmallGraph()
                    .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .trailing)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure HStack fills its container
        }
        .frame(maxWidth: 362, maxHeight: 72)  // Constrain the outer frame as per your dimensions
        .padding(16)
        .background(Constants.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(Constants.gray4, lineWidth: 1)
        )
    }
    }




#Preview {
    LandscapeInfoCard(activity: "Green Space Time",iconName: .sunLightIcon)
        .environmentObject(HealthManager())
}
