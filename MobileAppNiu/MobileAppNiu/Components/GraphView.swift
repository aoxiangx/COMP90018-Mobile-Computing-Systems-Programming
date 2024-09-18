//
//  GraphView.swift
//  MobileAppNiu
//
//  Created by Tori Li on 15/9/2024.
//

import SwiftUI

struct GraphView: View {
    var body: some View {
        VStack{
            NavigationView {
                VStack {
                    CustomNavigationBar(
                        title: "Daylight Time",
                        iconName: "sun.max.fill",
                        onBackButtonTap: {
                            // Handle back button tap
                            print("Back button tapped")
                        }
                    )
                    .navigationBarHidden(true)  // Hide default navigation bar
                    
                

                    
                    ExplainationView()
                    Spacer()
                }
            }
        }.padding(.horizontal, 16)
    }
}

#Preview {
    GraphView()
}
