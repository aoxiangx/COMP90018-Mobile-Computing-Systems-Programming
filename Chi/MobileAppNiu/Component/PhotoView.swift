//
//  PhotoView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 25/9/2024.
//

import SwiftUI

enum SwipeDirection {
    case left, right, top, bottom
}

struct PhotoView: View {
    @Binding var selectedImages: [UIImage] // 绑定外部传入的图片数组
    
    var onCardSwiped: ((SwipeDirection, Int) -> Void)? = nil // 回调滑动后的事件
    
    var body: some View {
        ZStack {
            ForEach(selectedImages.indices, id: \.self) { index in
                SwipableCardView(
                    image: selectedImages[index],
                    index: index,
                    onCardSwiped: { direction in
                        // 当滑动时，移除图片
                        selectedImages.remove(at: index)
                        onCardSwiped?(direction, index)
                    }
                )
                .id(UUID()) // 给每张图片唯一的标识，保证视图的更新
            }
            
            // 如果没有图片，显示默认图片
            if selectedImages.isEmpty {
                Image("BG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 320.6, height: 375.8)
                    .cornerRadius(16)
                    .rotationEffect(Angle(degrees: 4))
                    .shadow(radius: 2)
            }
        }
    }
}

struct SwipableCardView: View {
    var image: UIImage
    var index: Int
    var onCardSwiped: ((SwipeDirection) -> Void)? = nil
    
    @State private var offset = CGSize.zero
    @State private var isRemoved = false
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 320.6, height: 375.8)
                .cornerRadius(16)
                .rotationEffect(.degrees(Double(offset.width / 40)))
                .shadow(radius: 2)
                .offset(x: offset.width, y: offset.height * 0.4)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            withAnimation {
                                handleSwipe(offsetWidth: offset.width, offsetHeight: offset.height)
                            }
                        }
                )
                .opacity(isRemoved ? 0 : 1)
        }
    }
    
    func handleSwipe(offsetWidth: CGFloat, offsetHeight: CGFloat) {
        var swipeDirection: SwipeDirection = .left
        
        switch (offsetWidth, offsetHeight) {
        case (-500...(-150), _):
            swipeDirection = .left
            offset = CGSize(width: -500, height: 0)
            isRemoved = true
            onCardSwiped?(swipeDirection)
        case (150...500, _):
            swipeDirection = .right
            offset = CGSize(width: 500, height: 0)
            isRemoved = true
            onCardSwiped?(swipeDirection)
        case (_, -500...(-150)):
            swipeDirection = .top
            offset = CGSize(width: 0, height: -500)
            isRemoved = true
            onCardSwiped?(swipeDirection)
        case (_, 150...500):
            swipeDirection = .bottom
            offset = CGSize(width: 0, height: 500)
            isRemoved = true
            onCardSwiped?(swipeDirection)
        default:
            offset = .zero
        }
    }
}


