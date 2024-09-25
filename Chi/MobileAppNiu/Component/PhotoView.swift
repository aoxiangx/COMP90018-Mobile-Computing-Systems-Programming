//
//  PhotoView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 25/9/2024.
//

import SwiftUI

struct PhotoView: View {
    
    // input 3 images
    let image1: Image
    let image2: Image
    let image3: Image
    
    var body: some View {
        
        ZStack{
        
//            Image("BG")
            image1
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 320.6, height: 375.8)
                .cornerRadius(16)
                .rotationEffect(Angle(degrees: 5))
                .shadow(radius: 2)
            
//            Image("BG")
            image2
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 320.6, height: 375.8)
                .cornerRadius(16)
                .rotationEffect(Angle(degrees: -5))
                .offset(x: -5, y: 0)
                .shadow(radius: 2)
            
            
//            Image("BG")
            image3
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 320.6, height: 375.8)
                .cornerRadius(16)
                .rotationEffect(Angle(degrees: -15))
                .offset(x: -10, y: 0)
                .shadow(radius: 2)
            
        }
        
    }
}

#Preview {
    PhotoView(
        image1: Image("BG"),
        image2: Image("BG"),
        image3: Image("BG")
    )
}
