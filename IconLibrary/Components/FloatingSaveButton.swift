//
//  FloatingSaveButton.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/27.
//

import SwiftUI

struct FloatingSaveButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    var isWorking = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Image(systemName: systemImage)
                        .opacity(isWorking ? 0 : 1)
                    if isWorking {
                        ProgressView()
                            .tint(Theme.accentLabel)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                Text(titleKey)
            }
            .font(.rounded(.headline, weight: .semibold))
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .animation(.quickSpring, value: isWorking)
        }
        .buttonStyle(FloatingSaveButtonStyle())
        .disabled(isWorking)
        .padding([.trailing, .bottom], 16)
    }
}

private struct FloatingSaveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let shape = RoundedRectangle(
            cornerRadius: isPressed ? Theme.Corner.loose : Theme.Corner.card,
            style: .continuous
        )
        return configuration.label
            .foregroundColor(Theme.accentLabel)
            .floatingSurface(in: shape)
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.quickSpring, value: isPressed)
    }
}

private extension View {
    @ViewBuilder
    func floatingSurface<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.tint(Theme.accentFill).interactive(), in: shape)
        } else {
            background(Theme.accentFill, in: shape)
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 4)
        }
    }
}
