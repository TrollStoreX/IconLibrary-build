//
//  LoadingIndicator.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/26.
//

import SwiftUI

struct LoadingIndicator: View {
    static let size: CGFloat = 56

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle().fill(Theme.accentFill)
            if reduceMotion {
                ProgressView().tint(Theme.accentLabel)
            } else {
                TimelineView(.animation) { context in
                    let time = context.date.timeIntervalSinceReferenceDate
                    WavyCircle(waves: 8, amplitude: 0.07 + 0.05 * sin(time * 3))
                        .fill(Color.accentColor)
                        .rotationEffect(.radians(time * 2.4))
                        .padding(12)
                }
            }
        }
        .frame(width: Self.size, height: Self.size)
        .accessibilityHidden(true)
    }
}
