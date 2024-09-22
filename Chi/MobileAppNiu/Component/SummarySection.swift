//
//  SummarySection.swift
//  MobileAppNiu
//
//  Created by Tori Li on 19/9/2024.
//

import SwiftUI

struct SummarySection: View {
    var action:String
    var averageTime:String
    var iconName:ImageResource
    var body: some View {
        ZStack {
            VStack(alignment:.leading) {
                HStack {
                    Image(iconName)
                        .foregroundColor(.yellow)
                    Text(action)
                        .font(Font.custom("Roboto", size: 16))
                        .foregroundColor(Constants.gray3)
                }.frame(maxWidth:.infinity,alignment: .leading)
                
                Text(averageTime+" Mins")
                    .font(Font.custom("Roboto", size: 24))
                    .foregroundColor(Constants.gray3)
                Text("Past 7 Days")
                    .font(Font.custom("Roboto", size: 12))
                    .foregroundColor(Constants.gray3)
            }
                .padding(16)
                .frame(width: .infinity,height: 72)
            ZStack(alignment: .trailing) {
                Rectangle()
                    .fill(Constants.Yellow3) // Adjust opacity as needed
                    .frame(width: 217, height: 26) // Adjust size and position as needed
                    .cornerRadius(26)
                
                // used to extend the frame
                Rectangle()
                    .fill(Color.clear) // Adjust opacity as needed
                    .frame(width: .infinity, height: 26) // Adjust size and position as needed
                    .cornerRadius(26)
                
                ChartView(timePeriod: .day,hideDetail: true)
                    .scaleEffect(x: 1, y: 0.3)
                    .frame(maxWidth:217,maxHeight: 59,alignment: .trailing)
            }.frame(width: .infinity,height: 72)
        }
            .frame(maxWidth:362,maxHeight: 104)
            .cornerRadius(12)
//            .overlay(
//              RoundedRectangle(cornerRadius: 12)
//                .stroke(Color(red: 0.34, green: 0.35, blue: 0.35), lineWidth: 0.3)
//            )

            
        
    }
}

#Preview {
    SummarySection(action:"Green Space Time",averageTime: "24",iconName: .sunLightIcon)
}
