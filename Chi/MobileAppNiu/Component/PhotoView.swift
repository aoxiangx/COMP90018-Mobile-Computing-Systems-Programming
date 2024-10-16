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

    var body: some View {
        if images.isEmpty {
            Text("No images available")
                .font(.headline)
                .padding()
        } else {
            ZStack {
                // Loop through the images and display them in a stacked layout
                ForEach(images.indices, id: \.self) { index in
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
                        .offset(x: CGFloat(index - currentIndex) * 300) // Offset to simulate iOS background switch effect
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
        }
    }
}

#Preview {
    if let example1 = UIImage(named: "bg1"),
       let example2 = UIImage(named: "bg2"),
       let example3 = UIImage(named: "bg3") {
        PhotoCarouselView(images: [example1, example2, example3])
    } else {
        Text("Images not found")
    }
}

