//
//  JourneyView.swift
//  MobileAppNiu
//
//  Created by Aoxiang Xiao on 4/10/2024.
//

import SwiftUI

struct JourneyView: View {
    @State private var selectedImages: [UIImage] = [] // 保存上传的图片

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // Background
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFF8C9"), location: 0.0),
                    .init(color: Color(hex: "EDF5FF"), location: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)  // Fill the screen
                
                ScrollView { // 包裹内容，支持上下滚动
                    VStack(alignment: .leading) {
                        
                        // 为了与 HomeView 一致，顶部留有空间
                        VStack {
                            Spacer().frame(height: 50) // 留出与 HomeView 相同的顶部空间
                            
                            // Journey Title and PhotoButton on the same line
                            HStack {
                                Text("Journey")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                // 传入 `selectedImages` 绑定
                                PhotoButtonView(selectedImages: $selectedImages)
                                    .frame(width: 48, height: 32)
                            }
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            
                            // 调用新修改后的 PhotoView，传递选中的图片
                            PhotoView(selectedImages: selectedImages)
                                .frame(maxWidth: .infinity)

                            // CalendarView
                            VStack(alignment: .leading, spacing: 10) {
                                CalendarView() // 显示 CalendarView
                                    .padding([.leading, .trailing], 20)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    JourneyView()
}


