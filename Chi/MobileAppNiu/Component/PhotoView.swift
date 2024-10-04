//
//  PhotoView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 25/9/2024.
//

import SwiftUI

struct PhotoView: View {
    var selectedImages: [UIImage] = [] // 保存用户上传的图片
    
    var body: some View {
        TabView {
            if selectedImages.isEmpty {
                // 没有图片时，显示默认的 BG 图片
                ZStack {
                    Image("BG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320.6, height: 375.8)
                        .cornerRadius(16)
                        .rotationEffect(Angle(degrees: 4))
                        .shadow(radius: 2)

                    Image("BG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320.6, height: 375.8)
                        .cornerRadius(16)
                        .rotationEffect(Angle(degrees: -2))
                        .offset(x: -5, y: 0)
                        .shadow(radius: 2)
                    
                    Image("BG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320.6, height: 375.8)
                        .cornerRadius(16)
                        .rotationEffect(Angle(degrees: -8))
                        .offset(x: -10, y: 0)
                        .shadow(radius: 2)
                }
            } else {
                // 根据选择的图片展示，最多展示三张
                ForEach(0..<min(selectedImages.count, 3), id: \.self) { index in
                    ZStack {
                        if index == 2 {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 320.6, height: 375.8)
                                .cornerRadius(16)
                                .rotationEffect(Angle(degrees: -8))
                                .offset(x: -10, y: 0)
                                .shadow(radius: 2)
                        }
                        if index >= 1 {
                            Image(uiImage: selectedImages[index - 1])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 320.6, height: 375.8)
                                .cornerRadius(16)
                                .rotationEffect(Angle(degrees: -2))
                                .offset(x: -5, y: 0)
                                .shadow(radius: 2)
                        }
                        if index >= 0 {
                            Image(uiImage: selectedImages[index])
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
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 500)
    }
}



#Preview {
    PhotoView()
}
