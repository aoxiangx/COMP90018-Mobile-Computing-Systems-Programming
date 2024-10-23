//
//  CircleChartView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 21/9/2024.
//

import SwiftUI

struct CircleChartView: View {
    var score: Double  // Binding to the external score
    var message: String = "Keep it up!"

    var body: some View {
        VStack {
            ZStack {
                // Background gray circle
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        Constants.gray4, // Assuming Constants.gray4 is defined elsewhere
                        style: StrokeStyle(lineWidth: 21, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: 200, height: 200)

                // Foreground white circle
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        Constants.white,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: 200, height: 200)

                // Foreground progress circle
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.score / 100 * 0.75, 0.75)))
                    .stroke(
                        Constants.Yellow1,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: 200, height: 200)
                    .animation(.easeOut(duration: 0.3), value: score)

                VStack {
                    Text("\(Int(score))%")
                        .font(Constants.bigTitle)
                        .padding(.top, 24)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.gray3) // Assuming Constants.gray3 is defined elsewhere
                    VStack {
                        Text(warmingGreeting(for: Int(score)))
                            .font(Constants.caption)
                            .foregroundColor(Constants.gray3)
                        Text(emoji(for: Int(score)))
                            .font(.largeTitle)
                    }
                }
            }
        }
        .padding(24)
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

// Preview
struct CircleChartView_Previews: PreviewProvider {
    @State static var score = 75.0

    static var previews: some View {
        CircleChartView(score: score)
    }
}
