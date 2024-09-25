//
//  PhotoButtonView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 25/9/2024.
//

import SwiftUI
import PhotosUI
import Photos


struct PhotoButtonView: View {
    @State private var selectedItems: [PhotosPickerItem] = [] // 用于存储选中的照片
    @State private var selectedImages: [UIImage] = [] // 用于存储转换后的 UIImage
    @State private var showPicker = false // 控制 PhotosPicker 的显示

    var body: some View {
        VStack {
            // 上传照片按钮
            PhotosPicker(selection: $selectedItems, matching: .images) {
                ZStack {
                    // 黄色背景的按钮
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow)
                        .frame(width: 48, height: 32)
                    
                    // 灰色的加号图标
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
            .onChange(of: selectedItems) { newItems in
                for newItem in newItems {
                    Task {
                        do {
                            if let data = try await newItem.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                // 如果选中的图片数量小于3张，则添加
                                if selectedImages.count < 3 {
                                    selectedImages.append(image)
                                }
                            }
                        } catch {
                            print("Error loading image: \(error)")
                        }
                    }
                }
            }

            // 显示已选中的图片
            ForEach(selectedImages, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200) // 显示上传的照片
                    .padding()
            }
        }
    }
}


#Preview {
    PhotoButtonView()
}
