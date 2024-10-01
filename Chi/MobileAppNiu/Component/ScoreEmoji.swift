//
//  ScoreEmoji.swift
//  MobileAppNiu
//
//  Created by 关昊 on 1/10/2024.
//

import SwiftUI

struct ScoreEmoji: View {
    let score: Int

    var body: some View {
        VStack {
            Text("\(score)")
                .font(.largeTitle)
            Text(warmingGreeting(for: score))
                .font(.body)
            Text(emoji(for: score))
                .font(.largeTitle)
        }
        .padding()

    }

    private func emoji(for score: Int) -> String {
        switch score {
        case 0..<20:
            return "😵"  // Very poor
        case 20..<40:
            return "🫨"  // Poor
        case 40..<60:
            return "😉"  // Fair
        case 60..<80:
            return "😀"  // Good
        case 80...100:
            return "😃"  // Excellent
        default:
            return "🤔"  // Out of expected range
        }
    }
    private func warmingGreeting (for score: Int) -> String {
        switch score {
        case 0..<20:
            return "Get Out from Here"  // Very poor
        case 20..<40:
            return "You Deserve Better"  // Poor
        case 40..<60:
            return "Keep It Up"  // Fair
        case 60..<80:
            return "Nice Place"  // Good
        case 80...100:
            return "Wow Great!"  // Excellent
        default:
            return "🤔"  // Out of expected range
        }
    }
}

struct ScoreEmoji_Previews: PreviewProvider {
    static var previews: some View {
        ScoreEmoji(score: 45) // Example score for preview
    }
}
