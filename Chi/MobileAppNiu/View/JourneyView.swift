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
    
    // Mapping: Date string to array of image filenames
    @State private var imageFilenames: [String: [String]] = [:]
    
    private let userDefaultsKey = "JourneyViewImageFilenames"
    
    // State to show delete success alert
    @State private var showDeleteSuccessAlert = false
    
    var body: some View {
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
                        // Title
                        Text("Journey")
                            .font(Constants.bigTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.gray2)
                            .padding(.leading, 16)
                            .padding(.top, 16)
                        VStack {
                            
                            HStack {
                                
                                Spacer()
                                
                                // Photo upload button with callback to save images
                                PhotoButtonView(dateImages: $dateImages, selectedDate: $selectedDate, onImageAdded: saveImages)
                                    .frame(width: 48, height: 32)
                            }
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            
                            // Display selected images or placeholder
                            if let selectedDate = selectedDate, let images = dateImages[selectedDate] {
                                PhotoCarouselView(images: images, onDelete: { index in
                                    deleteImage(at: index)
                                })
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
            .onAppear {
                loadImages() // Load saved images on appearance
            }
            .alert(isPresented: $showDeleteSuccessAlert) {
                Alert(title: Text("Success"), message: Text("Photo has been successfully deleted."), dismissButton: .default(Text("OK")))
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
                            print("Loaded image for date \(dateString): \(filename)")
                        }
                    }
                    dateImages[date] = images
                }
            }
        }
    }
    
    /// Callback when new images are added, saves them and updates the mapping
    private func saveImages(for date: Date, images: [UIImage]) {
        let dateString = date.toString()
        var filenames = imageFilenames[dateString] ?? []
        
        // Save new images and get their filenames
        var savedImages: [UIImage] = []
        for image in images {
            if let filename = FileManager.saveImage(image) {
                filenames.append(filename)
                savedImages.append(image)
                print("Added image filename for date \(dateString): \(filename)")
            }
        }
        
        imageFilenames[dateString] = filenames
        dateImages[date] = (dateImages[date] ?? []) + savedImages
        saveImageFilenames() // Persist the mapping
    }
    
    /// Deletes the image at the specified index for the selected date
    private func deleteImage(at index: Int) {
        guard let selectedDate = selectedDate else { return }
        let dateString = selectedDate.toString()
        
        // Get the corresponding filename
        guard var filenames = imageFilenames[dateString] else { return }
        guard index < filenames.count else { return }
        let filename = filenames[index]
        
        // Delete the image file from the file system
        let fileURL = FileManager.documentsDirectory.appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Deleted image file: \(filename)")
        } catch {
            print("Error deleting image file: \(error)")
        }
        
        // Update the filenames mapping and images array
        filenames.remove(at: index)
        imageFilenames[dateString] = filenames
        saveImageFilenames()
        
        // Update `dateImages`
        dateImages[selectedDate]?.remove(at: index)
        
        // If no images remain for the date, remove the date entry
        if dateImages[selectedDate]?.isEmpty == true {
            dateImages.removeValue(forKey: selectedDate)
            imageFilenames.removeValue(forKey: dateString)
            saveImageFilenames()
        }
        
        // Show deletion success alert
        showDeleteSuccess()
    }
    
    /// Shows an alert indicating successful deletion
    private func showDeleteSuccess() {
        showDeleteSuccessAlert = true
    }
}

#Preview {
    JourneyView()
}
