//
//  SmallGraph.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 16/9/2024.
//

import SwiftUI
import Charts  // Ensure to import the Charts framework if using iOS 16 and above

struct LineData: Identifiable, Equatable {
    let id = UUID()
    let date: String
    let value: Double
    
    static func ==(lhs: LineData, rhs: LineData) -> Bool {
        return lhs.id == rhs.id && lhs.date == rhs.date && lhs.value == rhs.value
    }
    // Equatable is to implement animation for the graph 
}
struct SmallGraph: View {
    var activity: Activity
    func colorForActivity() -> Color {
           switch activity {
           case .green:
               return Constants.Green.opacity(0.3)
           case .daylight:
               return Constants.Yellow3
           case .hrv:
               return Constants.Purple
           case .noise:
               return Constants.Orange
           case .sleep:
               return Constants.Blue2
           case .steps:
               return Constants.Red
               
           }
       }
    var body: some View {
        ZStack {
            // Squeeze the chart vertically with scaleEffect
            ChartView(timePeriod: TimePeriod.week, hideDetail: true, activity: activity)
                .scaleEffect(x: 1, y: 0.3) // Adjusted to squeeze even more
                .frame(maxWidth: .infinity, maxHeight: 59)
//                .padding(.top, 30)
            
            // Add background rectangle
            
            Rectangle()
                .foregroundStyle(colorForActivity())
                .cornerRadius(12)
                .zIndex(-1)
                .frame(width: 217, height: 26)
        }
        .frame(width: 217, height: 59)
    }
}

struct SmallGraph_Previews: PreviewProvider {
    static var previews: some View {
        SmallGraph(activity: .green).environmentObject(HealthManager())
    }
}
