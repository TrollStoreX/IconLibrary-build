//
//  FlowStack.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/26.
//

import SwiftUI

struct FlowStack<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        if #available(iOS 16.0, *) {
            FlowLayout(spacing: 8) { content }
        } else {
            VStack(alignment: .leading, spacing: 8) { content }
        }
    }
}

@available(iOS 16.0, *)
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, in: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = arrange(subviews, in: bounds.width).frames
        for (subview, frame) in zip(subviews, frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(_ subviews: Subviews, in maxWidth: CGFloat) -> (frames: [CGRect], size: CGSize) {
        var frames: [CGRect] = []
        var origin = CGPoint.zero
        var rowHeight: CGFloat = 0
        var width: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            if origin.x > 0, origin.x + size.width > maxWidth {
                origin.x = 0
                origin.y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: origin, size: size))
            origin.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            width = max(width, origin.x - spacing)
        }
        return (frames, CGSize(width: width, height: origin.y + rowHeight))
    }
}
