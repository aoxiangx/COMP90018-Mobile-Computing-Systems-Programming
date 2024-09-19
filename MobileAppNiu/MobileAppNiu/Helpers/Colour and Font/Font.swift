//
//  Font.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 16/9/2024.
//

import SwiftUI

struct AppFonts {
    static func primary(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom("RedHat", size: size).weight(weight)
    }

    static func secondary(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom("YourSecondaryFontName", size: size).weight(weight)
    }
}
