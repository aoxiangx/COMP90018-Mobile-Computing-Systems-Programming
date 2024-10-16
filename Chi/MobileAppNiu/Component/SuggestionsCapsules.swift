//
//  SuggestionsCapsules.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 16/9/2024.
//
import SwiftUI
import HealthKit



struct SuggestionsCapsules: View {
    @ObservedObject var healthManager = HealthManager()
    @State private var currentPage: Int = 0
    
    let suggestions = ["Take a Walk in the Park", "Go for a Run when it's Sunny"] // Example suggestions
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Title
            Text("How to Improve")
                .font(Font.custom("Roboto", size: 24))
                .foregroundColor(Color(red: 0.34, green: 0.35, blue: 0.35))
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            // Horizontal ScrollView for Capsules
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 8) {
                        ForEach(suggestions.indices, id: \.self) { index in
                            SuggestionCapsule(text: suggestions[index])
                                .onTapGesture {
                                    withAnimation {
                                        currentPage = index
                                        print("Back button tapped ",index)
                                        // Scroll to the selected button
                                        proxy.scrollTo(currentPage, anchor: .center)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 0)
                    .padding(.top, 0)
                    .padding(.bottom, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack{
                ForEach(0..<suggestions.count, id: \.self) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .opacity(index == currentPage ? 1 : 0.5)
                        .padding(2) // Adjust spacing between indicators
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
        .frame(width: 377, alignment: .topLeading)
    }
}

struct SuggestionCapsule: View {
    var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(Constants.body)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Constants.Yellow1)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1)
        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 0.15)
                .stroke(Color(red: 0.34, green: 0.35, blue: 0.35), lineWidth: 0.3)
        )
    }
}


// Preview
struct SuggestionsCapsules_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsCapsules(healthManager: HealthManager())
    }
}
