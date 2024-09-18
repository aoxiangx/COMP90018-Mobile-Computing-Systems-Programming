//
//  ImproveTip.swift
//  MobileAppNiu
//
//  Created by Tori Li on 18/9/2024.
//

import SwiftUI

struct ImproveTip: View {
    let items = ["Take a Walk in the Park", "Go for a Run", "Meditate"]
    @State private var currentPage: Int = 0
    var body: some View {
        VStack(alignment: .leading) {
            Text("How to Improve")
                .font(.system(size: 24))
            
            // ScrollViewReader to programmatically scroll to the selected button
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(items.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    currentPage = index
                                    print("Back button tapped ",index)
                                    // Scroll to the selected button
                                    proxy.scrollTo(currentPage, anchor: .center)
                                }

                                // Action for the button
                            }) {
                                Text(items[index])
                                    .frame(width: 197, height: 40)
                                    .font(.system(size: 16))
                                    .background(Color.yellow)
                                    .foregroundColor(.gray)
                                    .cornerRadius(24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(currentPage != index ? Color.clear : Color.gray, lineWidth: 2) // Stroke color based on index
                                    )
                            }
                            .id(index) // Assign an ID to each button for scrolling
                        }
                    }
                }
                .frame(height: 40) // Adjust height to fit the buttons
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Custom page control
            HStack {
                ForEach(0..<items.count, id: \.self) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .opacity(index == currentPage ? 1 : 0.5)
                        .padding(2) // Adjust spacing between indicators
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ImproveTip()
}
