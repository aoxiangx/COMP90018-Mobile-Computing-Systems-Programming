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
    @State private var selectedDate: Date? = Calendar.current.startOfDay(for: Date()) // Standardize to today's start
    @State private var cachedImages: [UIImage] = []
    
    // File names mapping: Date string to array of image filenames
    @State private var imageFilenames: [String: [String]] = [:]
    
    private let userDefaultsKey = "JourneyViewImageFilenames"
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // Background gradient
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
                                .frame(minHeight: 20) // Top padding
                            
                            HStack {
                                // Title
                                Text("Journey")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                // Photo upload button
                                PhotoButtonView(dateImages: $dateImages, selectedDate: $selectedDate, onImageAdded: saveImages)
                                    .frame(width: 48, height: 32)
                            }
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            
                            // Display selected images or placeholder
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
                                // Calendar view
                                CalendarView(selectedDate: $selectedDate)
                                    .padding([.leading, .trailing], 20)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadImages()
        }
        .onChange(of: selectedDate) { _ in
            // Optional: Handle any updates when selectedDate changes
        }
    }
    
    // MARK: - Data Persistence Methods
    
    /// Saves the image filenames mapping to UserDefaults
    private func saveImageFilenames() {
        UserDefaults.standard.setValue(imageFilenames, forKey: userDefaultsKey)
    }
    
    /// Loads the image filenames mapping from UserDefaults and populates `dateImages`
    private func loadImages() {
        if let savedFilenames = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: [String]] {
            imageFilenames = savedFilenames
            for (dateString, filenames) in imageFilenames {
                if let date = Date.fromString(dateString) {
                    var images: [UIImage] = []
                    for filename in filenames {
                        if let image = FileManager.loadImage(named: filename) {
                            images.append(image)
                        }
                    }
                    dateImages[date] = images
                }
            }
        }
    }
    
    /// Callback when images are added to save the updated mapping
    private func saveImages(for date: Date, images: [UIImage]) {
        let dateString = date.toString()
        var filenames = imageFilenames[dateString] ?? []
        
        // Remove existing images from storage if replacing
        // (Optional: Implement if you want to allow image replacement)
        
        // Save new images
        var savedImages: [UIImage] = []
        for image in images {
            if let filename = FileManager.saveImage(image) {
                filenames.append(filename)
                savedImages.append(image)
            }
        }
        
        imageFilenames[dateString] = filenames
        dateImages[date] = savedImages
        saveImageFilenames()
    }
}

#Preview {
    JourneyView()
}
