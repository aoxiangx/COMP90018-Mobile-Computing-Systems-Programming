//
//  CustomNavigationBar.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//
import SwiftUI

struct CustomNavigationBar: View {
    var title: String
    var iconName: String
    var onBackButtonTap: () -> Void

    var body: some View {
        ZStack {
            // Centered Title and Icon
            HStack {
                Spacer()
                HStack {
                    Image(systemName: iconName)
                        .foregroundColor(.yellow)  // Customize the icon color
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary) // Customize the title style
                }
                Spacer()
            }
          
            // Overlay for Back Button
            HStack {
                Button(action: {
                    onBackButtonTap()  // Action for back button
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .padding()
                }
                Spacer()
            }
        
        }
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(
            title: "Daylight Time",
            iconName: "sun.max.fill",
            onBackButtonTap: {
                print("Back button tapped")
            }
        )
        .previewLayout(.sizeThatFits) // Fits the preview size
        .padding() // Adds some padding around the preview
    }
}
