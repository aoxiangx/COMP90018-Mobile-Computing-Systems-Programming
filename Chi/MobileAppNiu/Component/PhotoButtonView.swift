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

    var body: some View {
        VStack {
            Button(action: {
                showActionSheet = true
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
                            showPhotosPicker = true
                        },
                        .default(Text("Camera")) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                sourceType = .camera
                                showImagePicker = true
                            } else {
                                alertMessage = "Camera is not available on this device."
                                showAlert = true
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItems, matching: .images)
            .onChange(of: selectedItems) { newItems in
                Task {
                    for newItem in newItems {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            if let selectedDate = selectedDate {
                                var images = dateImages[selectedDate] ?? []
                                if images.count < 5 {
                                    images.append(image)
                                    dateImages[selectedDate] = images
                                } else {
                                    alertMessage = "You can only add up to 5 images per date."
                                    showAlert = true
                                }
                            } else {
                                alertMessage = "Please select a date first."
                                showAlert = true
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: sourceType) { image in
                    if let selectedDate = selectedDate {
                        var images = dateImages[selectedDate] ?? []
                        images.append(image)
                        dateImages[selectedDate] = images
                    } else {
                        alertMessage = "Please select a date first."
                        showAlert = true
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// Custom ImagePicker to handle camera and photo library
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            DispatchQueue.main.async {
                picker.dismiss(animated: true)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                picker.dismiss(animated: true)
            }
        }
    }
}

#Preview {
    PhotoButtonView(dateImages: .constant([:]), selectedDate: .constant(nil))
}
