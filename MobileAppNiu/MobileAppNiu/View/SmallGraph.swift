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
    let data: [LineData] = [
        LineData(date: "09/01", value: 75.0),
        LineData(date: "09/02", value: 82.5),
        LineData(date: "09/03", value: 91.0),
        LineData(date: "09/04", value: 68.4),
        LineData(date: "09/05", value: 80.2),
        LineData(date: "09/06", value: 80.2),
        LineData(date: "09/07", value: 75.0),
    ]
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .symbol(Circle().strokeBorder())
                .foregroundStyle(Constants.gray3)
            }
            
            
            // Example: Highlighting values from 09/01 to 09/05 within a value range
            if let first = data.first(where: { $0.date == "09/01" }),
               let last = data.first(where: { $0.date == "09/07" }) {
                RectangleMark(
                    xStart: .value("Start Date", first.date),
                    xEnd: .value("End Date", last.date),
                    yStart: .value("Start Value", 75),
                    yEnd: .value("End Value", 90)
                )
                .foregroundStyle(Color.yellow.opacity(0.3))
                .cornerRadius(12)
                .zIndex(-1)
            }
        }
        
        .frame(width:.infinity, height: .infinity)

        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .animation(.spring(response: 1, dampingFraction: 0.6, blendDuration: 2), value: data)
        
    }
}

struct SmallGraph_Previews: PreviewProvider {
    static var previews: some View {
        SmallGraph()
    }
}
