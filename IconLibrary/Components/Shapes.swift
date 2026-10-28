//
//  Shapes.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/25.
//

import SwiftUI

struct GroupedRowShape: Shape {
    var topRadius: CGFloat
    var bottomRadius: CGFloat

    static let pressed = GroupedRowShape(topRadius: Theme.Corner.loose, bottomRadius: Theme.Corner.loose)

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(topRadius, bottomRadius) }
        set {
            topRadius = newValue.first
            bottomRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let limit = min(rect.width, rect.height) / 2
        let top = min(topRadius, limit)
        let bottom = min(bottomRadius, limit)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + top, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - top, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - top, y: rect.minY + top), radius: top,
                    startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottom))
        path.addArc(center: CGPoint(x: rect.maxX - bottom, y: rect.maxY - bottom), radius: bottom,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bottom, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottom, y: rect.maxY - bottom), radius: bottom,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + top))
        path.addArc(center: CGPoint(x: rect.minX + top, y: rect.minY + top), radius: top,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

enum RowPosition {
    case single, first, middle, last

    init(index: Int, count: Int) {
        switch (index, count) {
        case (_, 1): self = .single
        case (0, _): self = .first
        case (count - 1, _): self = .last
        default: self = .middle
        }
    }

    var shape: GroupedRowShape {
        let outer = Theme.Corner.card
        let inner = Theme.Corner.tight
        switch self {
        case .single: return GroupedRowShape(topRadius: outer, bottomRadius: outer)
        case .first: return GroupedRowShape(topRadius: outer, bottomRadius: inner)
        case .middle: return GroupedRowShape(topRadius: inner, bottomRadius: inner)
        case .last: return GroupedRowShape(topRadius: inner, bottomRadius: outer)
        }
    }
}

struct WavyCircle: Shape {
    var waves: Int
    var amplitude: CGFloat

    var animatableData: CGFloat {
        get { amplitude }
        set { amplitude = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let baseRadius = outerRadius * (1 - amplitude)
        let points = stride(from: 0, to: 2 * CGFloat.pi, by: .pi / 120).map { angle -> CGPoint in
            let radius = baseRadius + outerRadius * amplitude * cos(CGFloat(waves) * angle)
            return CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        }

        var path = Path()
        path.addLines(points)
        path.closeSubpath()
        return path
    }
}
