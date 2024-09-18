//
//  SummarySection.swift
//  MobileAppNiu
//
//  Created by Tori Li on 18/9/2024.
//

import SwiftUI

struct SummarySection: View {
    var action:String
    var averageTime:String
    var iconName:String
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Image(systemName: iconName)
                        .foregroundColor(.yellow)
                    Text(action)
                }
                Text(averageTime+" Mins")
                Text("Past 7 Days")
            }
                .frame(width: 150, height: 74) //
                .padding(12)
            ZStack {
                ChartView(timePeriod: .day,hideDetail: true)
                    .scaleEffect(x: 1, y: 0.3)
                .frame(maxWidth:217,maxHeight: 59)
                Rectangle()
                    .fill(Color.yellow.opacity(0.3)) // Adjust opacity as needed
                    .frame(width: 217, height: 26) // Adjust size and position as needed
                    .cornerRadius(26)
            }.frame(width: 217, height: 74) //
        }
            .frame(maxWidth:.infinity,maxHeight: 106)
            .overlay(
                RoundedRectangle(cornerRadius: 12) // Overlay to apply the border
                    .stroke(Color.gray, lineWidth: 2) // Border color and width
            )
            .padding(12)

            
        
    }
}

#Preview {
    SummarySection(action:"Daylight Time",averageTime: "24",iconName: "sun.max.fill")
}
