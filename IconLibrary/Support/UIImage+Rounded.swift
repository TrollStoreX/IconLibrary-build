//
//  UIImage+Rounded.swift
//  IconLibrary
//
//  Created by iosdump on 2026/10/2.
//

import UIKit

extension UIImage {
    func withCornerRadius(_ cornerRadius: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        format.preferredRange = .standard

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let bounds = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
            draw(in: bounds)
        }
    }
}
