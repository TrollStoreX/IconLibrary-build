//
//  ButtonStyles.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/25.
//

import SwiftUI

struct GroupedRowButtonStyle: ButtonStyle {
    let position: RowPosition

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        return configuration.label
            .background(
                isPressed ? Theme.mutedFill : Theme.cardBackground,
                in: isPressed ? GroupedRowShape.pressed : position.shape
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.quickSpring, value: isPressed)
    }
}

struct RoundIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        return configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(Theme.highlightLabel)
            .padding(11)
            .frame(minWidth: 44, minHeight: 44)
            .background(
                Theme.highlightFill,
                in: RoundedRectangle(cornerRadius: isPressed ? Theme.Corner.regular : 22, style: .continuous)
            )
            .scaleEffect(isPressed ? 0.92 : 1)
            .animation(.quickSpring, value: isPressed)
    }
}

struct TagButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: isPressed ? 18 : 10, style: .continuous)
        return configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isPressed ? Theme.highlightFill : Theme.cardBackground, in: shape)
            .overlay(shape.strokeBorder(Theme.separator, lineWidth: isPressed ? 0 : 1))
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.quickSpring, value: isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.quickSpring, value: configuration.isPressed)
    }
}
