//
//  Landscape Info Card.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 16/9/2024.
//

import SwiftUI

struct LandscapeInfoCard: View {
    var body: some View {
            VStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {  // Adjusted spacing to match the design
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 4) {
                            Image("Sun_Light_Icon")
                              .frame(width: 16, height: 16)
                            Text("Daylight Time")
                              .font(Font.custom("Switzer", size: 16))
                              .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                        }
                        .padding(.vertical, 3)

                        Text("24 Min")
                          .font(Font.custom("Roboto", size: 24))
                          .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))

                        Text("Past 7 Days")
                          .font(Font.custom("Roboto", size: 12))
                          .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)) // Maintain spacing for text

                    VStack(alignment: .center, spacing: 0) {  // Reduced spacing inside VStack containing SmallGraph
                        SmallGraph()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensure HStack fills its container
            }
            .frame(maxWidth: 362, maxHeight: 72)  // Constrain the outer frame as per your dimensions
            .padding()
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
    LandscapeInfoCard()
}
