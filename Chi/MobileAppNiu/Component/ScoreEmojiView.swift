//
//  ScoreEmoji.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 23/9/2024.
//

import SwiftUI

struct ScoreEmojiView: View {
    @Binding var score: Int  // Use Binding to allow the parent view to manage the score

    var body: some View {
        ZStack {
            CircleChartView(score: Binding<Double>(get: {
                Double(self.score)  // Convert Int to Double
            }, set: { newValue in
                self.score = Int(newValue)  // Convert Double back to Int if needed
            }))
            
            VStack {
//                Text("\(score)%")
//                    .font(.largeTitle)
//                Text(warmingGreeting(for: score))
//                    .font(.body)
                Text(emoji(for: score))
                    .font(.largeTitle)
            }
            .padding()
        }
    }

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
        ScoreEmojiView(score: .constant(75))  // Use a constant for preview
    }
}
