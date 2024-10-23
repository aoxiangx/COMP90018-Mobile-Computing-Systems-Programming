//
//  Landscape Info Card.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 16/9/2024.
//

import SwiftUI


struct LandscapeInfoCard: View {
    var activity: Activity
    var iconName: ImageResource
    var subtitle:String
    @State private var average: Double = 0.0
    @State private var hasFetchedAverage: Bool = false
    @EnvironmentObject var manager: HealthManager
    var body: some View {
        ZStack(alignment: .center) {
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 4) {
                    Image(iconName)
                        .frame(width: 16, height: 16)
                    Text(activity.title)
                        .font(Font.custom("Switzer", size: 16))
                        .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                        .frame(maxWidth:.infinity,alignment: .leading)
                }
                .padding(.vertical, 3)
                
                
                if activity == .hrv {
                    if average < 30 {
                        Text("High")
                            .font(.system(size: 24))
                            .lineLimit(1)
                            .foregroundColor(Constants.gray3)
                            .fixedSize(horizontal: true, vertical: true)
                    } else if average <= 50 {
                        Text("Medium")
                            .font(.system(size: 24))
                            .lineLimit(1)
                            .foregroundColor(Constants.gray3)
                            .fixedSize(horizontal: true, vertical: true)
                    } else {
                        Text("Low")
                            .font(.system(size: 24))
                            .lineLimit(1)
                            .foregroundColor(Constants.gray3)
                            .fixedSize(horizontal: true, vertical: true)
                    }
                    
                } else {
                    HStack {
                        Text(String(format: "%.1f", average))
                            .font(.system(size: 24))
                            .lineLimit(1)
                            .foregroundColor(Constants.gray3)
                            .fixedSize(horizontal: true, vertical: true)
                        
                        Text(subtitle)
                            .font(Constants.caption)
                            .lineLimit(1)
                            .foregroundColor(Constants.gray3)
                    }

//                    Text(subtitle)
//                        .font(Constants.caption)
//                        .lineLimit(1)
//                        .foregroundColor(Constants.gray3)
                }
                    
                
                Text("Past 7 Days")
                    .font(Font.custom("Roboto", size: 12))
                    .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // Maintain spacing for text
            
            VStack(spacing: 0) {  // Reduced spacing inside VStack containing SmallGraph
                SmallGraph(activity:activity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .trailing)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure HStack fills its container
        }
        .onAppear {
            if !hasFetchedAverage {
                fetchAverage(activity: activity, period: TimePeriod.week)
                hasFetchedAverage = true // Set the flag to true after fetching
                print("fetchedAverage: \(hasFetchedAverage)")
            }
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
    private func fetchAverage(activity: Activity,period: TimePeriod) {
        if(activity == Activity.green){
            let greenSpaceManager = GreenSpaceManager()
            let (labels, greenSpaceTimes) = greenSpaceManager.fetchGreenSpaceTimes(for: period)
            // Calculate the sum of greenSpaceTimes
            let sumOfGreenSpaceTimes = greenSpaceTimes.reduce(0, +) // Sum all values in the array
            if period == .day{
                self.average = greenSpaceTimes.isEmpty ? 0 : sumOfGreenSpaceTimes
            }else{
                // Calculate the average (if the array is not empty)
                self.average = greenSpaceTimes.isEmpty ? 0 : sumOfGreenSpaceTimes / Double(greenSpaceTimes.count)
            }
            
        }
        else{
            manager.fetchAverage(endDate: Date(), activity: activity,period: period) { fetchedAverage in
                DispatchQueue.main.async {
                    self.average = fetchedAverage
                    //                print("Average for \(activity.title): \(fetchedAverage)")
                }
            }
        }
    }
}


#Preview {
    LandscapeInfoCard(activity: .daylight,iconName: .sunLightIcon,subtitle: "sd").environmentObject(HealthManager())
}
