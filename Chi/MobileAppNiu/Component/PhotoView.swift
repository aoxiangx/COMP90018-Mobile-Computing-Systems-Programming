//
//  PhotoView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 25/9/2024.
//

import SwiftUI
import PhotosUI

// MARK: - PhotoCarouselView
struct PhotoCarouselView: View {
    let images: [UIImage] // Array of images to display in the carousel
    @State private var currentIndex: Int = 0 // Index of the currently displayed image
    
    // Callback to handle image deletion
    var onDelete: ((Int) -> Void)?
    
    var body: some View {
        if images.isEmpty {
            Text("No images available")
                .font(.headline)
                .padding()
        } else {
            ZStack {
                // Loop through the images and display them in a stacked layout
                ForEach(images.indices, id: \.self) { index in
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 320.6, height: 375.8)
                            .cornerRadius(16)
                            .rotationEffect(Angle(degrees: 4))
                            .shadow(radius: 2)
                            .frame(maxWidth: .infinity)
                            .opacity(index == currentIndex ? 1 : 0.5)
                            .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                            .animation(.spring(), value: currentIndex)
                            .offset(x: CGFloat(index - currentIndex) * 300)

                        if index == currentIndex {
                            Button(action: {
                                // Confirm deletion
                                confirmDelete(at: index)
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.red)
                                    .padding(8)
                            }
                            .zIndex(2) // button at the top
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // Update current index based on swipe direction
                        if value.translation.width < 0 {
                            currentIndex = (currentIndex + 1) % images.count
                        } else if value.translation.width > 0 {
                            currentIndex = (currentIndex - 1 + images.count) % images.count
                        }
                    }
            )
            .contentShape(Rectangle())
        }
    }
    
    /// Presents a confirmation alert before deleting an image
    private func confirmDelete(at index: Int) {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let rootVC = window.rootViewController else { return }
        
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            onDelete?(index) // Call the delete callback
        }))
        
        rootVC.present(alert, animated: true, completion: nil)
    }
}

#Preview {
    if let example1 = UIImage(named: "bg1"),
       let example2 = UIImage(named: "bg2"),
       let example3 = UIImage(named: "bg3") {
        PhotoCarouselView(images: [example1, example2, example3], onDelete: { index in
            print("Delete index: \(index)")
        })
    } else {
        Text("Images not found")
    }
}
