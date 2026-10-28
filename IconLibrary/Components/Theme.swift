//
//  Theme.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/22.
//

import SwiftUI
import UIKit

enum Theme {
    static let background = Color(light: 0xFEF7FF, dark: 0x141218)
    static let cardBackground = Color(light: 0xF3EDF7, dark: 0x211F26)
    static let mutedFill = Color(light: 0xECE6F0, dark: 0x2B2930)
    static let accentFill = Color(light: 0xEADDFF, dark: 0x4F378B)
    static let accentLabel = Color(light: 0x4F378B, dark: 0xEADDFF)
    static let highlightFill = Color(light: 0xE8DEF8, dark: 0x4A4458)
    static let highlightLabel = Color(light: 0x4A4458, dark: 0xE8DEF8)
    static let secondaryText = Color(light: 0x49454F, dark: 0xCAC4D0)
    static let separator = Color(light: 0xCAC4D0, dark: 0x49454F)
    static let toastBackground = Color(light: 0x322F35, dark: 0xE6E0E9)
    static let toastText = Color(light: 0xF5EFF7, dark: 0x322F35)
    static let toastSuccess = Color(light: 0xD0BCFF, dark: 0x6750A4)
    static let toastError = Color(light: 0xF2B8B5, dark: 0xB3261E)
    static let shimmer = Color(light: 0xFFFFFF, dark: 0x3B383E)

    enum Corner {
        static let tight: CGFloat = 6
        static let regular: CGFloat = 12
        static let card: CGFloat = 20
        static let loose: CGFloat = 28
    }
}

extension Animation {
    static let appSpring = Animation.spring(response: 0.45, dampingFraction: 0.8)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.85)
}

extension Font {
    static func rounded(_ style: TextStyle, weight: Weight = .bold) -> Font {
        .system(style, design: .rounded).weight(weight)
    }
}

extension UIFont {
    static func rounded(_ style: TextStyle, weight: Weight) -> UIFont {
        let size = UIFont.preferredFont(forTextStyle: style).pointSize
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = font.fontDescriptor.withDesign(.rounded) else { return font }
        return UIFont(descriptor: descriptor, size: size)
    }
}

private extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
