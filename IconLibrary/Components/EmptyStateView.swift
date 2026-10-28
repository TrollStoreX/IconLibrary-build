//
//  EmptyStateView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/26.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    var title: Text?
    var message: Text?
    var retry: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .title) private var badgeSize: CGFloat = 104
    @State private var isVisible = false

    var body: some View {
        StatusLayout(anchorHeight: badgeSize) {
            VStack(spacing: 20) {
                badge
                VStack(spacing: 6) {
                    title?
                        .font(.rounded(.title3))
                        .foregroundColor(.primary)
                    message?
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                }
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1 : 0)

                if let retry {
                    Button(action: retry) {
                        Label("retry", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Theme.highlightLabel)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Theme.highlightFill, in: Capsule())
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .onAppear {
            guard !isVisible else { return }
            if reduceMotion {
                isVisible = true
            } else {
                withAnimation(.appSpring) { isVisible = true }
            }
        }
    }

    private var badge: some View {
        ZStack {
            WavyCircle(waves: 9, amplitude: 0.06)
                .fill(Theme.accentFill)
            Image(systemName: systemImage)
                .font(.system(size: badgeSize * 0.36, weight: .semibold))
                .foregroundColor(Theme.accentLabel)
        }
        .frame(width: badgeSize, height: badgeSize)
        .scaleEffect(isVisible ? 1 : 0.6)
        .rotationEffect(.degrees(isVisible ? 0 : -40))
        .opacity(isVisible ? 1 : 0)
        .accessibilityHidden(true)
    }
}

struct StatusLayout<Content: View>: View {
    let anchorHeight: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            content
                .padding(.horizontal, 32)
                .frame(width: proxy.size.width)
                .padding(.top, max(0, proxy.size.height * 0.42 - anchorHeight / 2))
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .ignoresSafeArea()
    }
}
