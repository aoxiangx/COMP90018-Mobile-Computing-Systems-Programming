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
    
    var body: some View {
        ZStack {
            ChartView(timePeriod: TimePeriod.week, hideDetail: true,activity: .stepCount)
            .scaleEffect(x: 1, y: 0.5)
            .frame(maxWidth: .infinity, maxHeight: 59)
            .padding(.top,30)
            
          
            Rectangle()
            .foregroundStyle(Color.yellow.opacity(0.3))
            .cornerRadius(12)
            .zIndex(-1)
            .frame(width:217, height: 26)
        
        }
        
        .frame(width:217, height: 59)

        
    }
}

struct SmallGraph_Previews: PreviewProvider {
    static var previews: some View {
        SmallGraph()
    }
}
