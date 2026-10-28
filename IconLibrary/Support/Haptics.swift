//
//  Haptics.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/29.
//

import UIKit

@MainActor
enum Haptics {
    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
