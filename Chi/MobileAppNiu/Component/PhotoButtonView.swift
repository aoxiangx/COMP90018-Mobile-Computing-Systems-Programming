//
//  PhotoButtonView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 25/9/2024.
//

import SwiftUI
import PhotosUI

struct PhotoButtonView: View {
    @Binding var dateImages: [Date: [UIImage]]
    @Binding var selectedDate: Date?
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showImagePicker = false
    @State private var showPhotosPicker = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var onImageAdded: ((Date, [UIImage]) -> Void)?
    
    private func checkImageLimit() -> Bool {
        print("➡️ Checking image limit...")
        print("📅 Selected date: \(String(describing: selectedDate))")
        
        guard let selectedDate = selectedDate else {
            print("❌ No date selected")
            alertMessage = "Please select a date first."
            showAlert = true
            return false
        }
        
        let currentCount = dateImages[selectedDate]?.count ?? 0
        print("🖼️ Current images count: \(currentCount)")
        
        
        print("✅ Below limit, can add more images")
        return true
    }
    
    var body: some View {
        VStack {
            Button(action: {
                print("🔘 Button tapped")
                showActionSheet = true  // Remove the checkImageLimit here
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow)
                        .frame(width: 48, height: 32)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 16, height: 2)
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 2, height: 16)
                    }
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Choose Photo Source"),
                    message: Text("Please select a source to upload photos"),
                    buttons: [
                        .default(Text("Photo Library")) {
                            print("📚 Photo Library selected")
                            if checkImageLimit() {
                                showPhotosPicker = true
                            }
                        },
                        .default(Text("Camera")) {
                            print("📸 Camera selected")
                            if checkImageLimit() {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    sourceType = .camera
                                    showImagePicker = true
                                } else {
                                    alertMessage = "Camera is not available on this device."
                                    showAlert = true
                                }
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItems, matching: .images)
            .onChange(of: selectedItems) { newItems in
                print("📸 Photos picker selection changed")
                Task {
                    if !checkImageLimit() {
                        selectedItems = []
                        return
                    }
                    
                    var newImages: [UIImage] = []
                    for newItem in newItems {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            if let selectedDate = selectedDate {
                                let currentCount = dateImages[selectedDate]?.count ?? 0
                                if currentCount + newImages.count < 5 {
                                    newImages.append(image)
                                } else {
                                    print("❌ Limit would be exceeded with new images")
                                    alertMessage = "You can only add up to 5 images per date. Please delete some images first."
                                    showAlert = true
                                    break
                                }
                            }
                        }
                    }
                    if !newImages.isEmpty, let selectedDate = selectedDate {
                        print("✅ Adding \(newImages.count) new images")
                        onImageAdded?(selectedDate, newImages)
                    }
                    selectedItems = []
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: sourceType) { image in
                    print("📸 Image picked from camera/library")
                    if checkImageLimit() {
                        if let selectedDate = selectedDate {
                            onImageAdded?(selectedDate, [image])
                        }
                    }
                }
            }
        }
        .alert("Notice", isPresented: $showAlert, actions: {
            Button("OK") {
                print("🔔 Alert dismissed")
                showAlert = false
            }
        }, message: {
            Text(alertMessage)
        })
        .onChange(of: showAlert) { newValue in
            print("🔔 Alert state changed to: \(newValue)")
            print("📝 Alert message: \(alertMessage)")
        }
    }
}

#Preview {
    PhotoButtonView(dateImages: .constant([:]), selectedDate: .constant(nil)) { _, _ in }
}

#Preview {
    PhotoButtonView(dateImages: .constant([:]), selectedDate: .constant(nil), onImageAdded: { date, images in
        // Handle image saving logic
    })
}

