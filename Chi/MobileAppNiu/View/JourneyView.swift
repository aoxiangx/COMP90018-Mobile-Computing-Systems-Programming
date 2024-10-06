//
//  JourneyView.swift
//  MobileAppNiu
//
//  Created by Aoxiang Xiao on 4/10/2024.
//

import SwiftUI
import PhotosUI


// MARK: - JourneyView
struct JourneyView: View {
    @State private var dateImages: [Date: [UIImage]] = [:]
    @State private var selectedDate: Date? = Date() // Set default to today
    @State private var cachedImages: [UIImage] = []

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // Background gradient for the entire view
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFF8C9"), location: 0.0),
                    .init(color: Color(hex: "EDF5FF"), location: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack {
                            Spacer()
                                .frame(minHeight: 20) // Space at the top for padding
                            
                            HStack {
                                // Title for the Journey section
                                Text("Journey")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                // Photo button for adding images
                                PhotoButtonView(dateImages: $dateImages, selectedDate: $selectedDate)
                                    .frame(width: 48, height: 32)
                            }
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            
                            // Display selected images or placeholder if no images
                            if let selectedDate = selectedDate, let images = dateImages[selectedDate] {
                                PhotoCarouselView(images: images)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Image("BG")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 320.6, height: 375.8)
                                    .cornerRadius(16)
                                    .rotationEffect(Angle(degrees: 4))
                                    .shadow(radius: 2)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                // Calendar view for selecting a date
                                CalendarView(selectedDate: $selectedDate)
                                    .padding([.leading, .trailing], 20)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    JourneyView()
}








