//
//  ScoreEmoji.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 23/9/2024.
//

import SwiftUI

struct ScoreEmojiView: View {
    var score: Int  // Keep score as a regular variable

    var body: some View {
        ZStack {
            // Ensure CircleChartView is correctly defined elsewhere in the project
            CircleChartView(score: Double(score))
            
            VStack {
                Text(emoji(for: score))
                    .font(.largeTitle)
            }
            .padding()
        }
    }

    // Function to return emojis based on score ranges
    private func emoji(for score: Int) -> String {
        switch score {
        case 0..<20: return "😵"
        case 20..<40: return "🫨"
        case 40..<60: return "😉"
        case 60..<80: return "😀"
        case 80...100: return "😃"
        default: return "🤔"
        }
    }

    // Function to return warming messages based on score ranges (optional)
    private func warmingGreeting(for score: Int) -> String {
        switch score {
        case 0..<20: return "Get Out from Here"
        case 20..<40: return "You Deserve Better"
        case 40..<60: return "Keep It Up"
        case 60..<80: return "Nice Place"
        case 80...100: return "Wow Great!"
        default: return "Check Your Score"
        }
    }
}

struct ScoreEmoji_Previews: PreviewProvider {
    static var previews: some View {
        ScoreEmojiView(score: 75)  // Example score for preview
    }
}
