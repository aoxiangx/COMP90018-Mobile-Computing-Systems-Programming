//
//  PhotoButtonView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 25/9/2024.
//

import SwiftUI
import PhotosUI

struct PhotoButtonView: View {
    @Binding var selectedImages: [UIImage] // 绑定外部传入的图片数组，更新图片
    @State private var selectedItems: [PhotosPickerItem] = [] // 用于保存 PhotosPicker 选择的项目

    var body: some View {
        PhotosPicker(selection: $selectedItems, matching: .images) {
            ZStack {
                // 背景按钮样式
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow)
                    .frame(width: 48, height: 32)
                
                // 中间的加号图标
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
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        // 将图片添加到 selectedImages 数组中
                        selectedImages.append(image)
                        
                        // 确保数组最多保存3张图片
                        if selectedImages.count > 3 {
                            selectedImages.removeFirst()
                        }
                    }
                }
            }
        }
    }
}



