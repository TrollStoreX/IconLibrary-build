//
//  IconSettings.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/22.
//

import Combine
import Foundation

enum IconResolution: String, CaseIterable {
    case size256 = "256x256"
    case size512 = "512x512"
    case size1024 = "1024x1024"
}

@MainActor
final class IconSettings: ObservableObject {
    static let shared = IconSettings()

    static let cornerRadiusRange: ClosedRange<Double> = 0.02...0.5

    private enum Keys {
        static let saveAsRounded = "saveAsRounded"
        static let saveAsSlightlyRounded = "saveAsSlightlyRounded"
        static let useCustomCornerRadius = "useCustomCornerRadius"
        static let customCornerRadiusRatio = "customCornerRadiusRatio"
        static let iconResolution = "iconResolution"
        static let saveOriginalPNG = "saveOriginalPNG"
    }

    private let defaults = UserDefaults.standard

    @Published var saveAsRounded: Bool {
        didSet {
            defaults.set(saveAsRounded, forKey: Keys.saveAsRounded)
            if saveAsRounded {
                saveAsSlightlyRounded = false
                useCustomCornerRadius = false
                saveOriginalPNG = false
            }
        }
    }

    @Published var saveAsSlightlyRounded: Bool {
        didSet {
            defaults.set(saveAsSlightlyRounded, forKey: Keys.saveAsSlightlyRounded)
            if saveAsSlightlyRounded {
                saveAsRounded = false
                useCustomCornerRadius = false
                saveOriginalPNG = false
            }
        }
    }

    @Published var useCustomCornerRadius: Bool {
        didSet {
            defaults.set(useCustomCornerRadius, forKey: Keys.useCustomCornerRadius)
            if useCustomCornerRadius {
                saveAsRounded = false
                saveAsSlightlyRounded = false
                saveOriginalPNG = false
            }
        }
    }

    @Published var customCornerRadiusRatio: Double {
        didSet {
            defaults.set(customCornerRadiusRatio, forKey: Keys.customCornerRadiusRatio)
        }
    }

    @Published var resolution: IconResolution {
        didSet {
            defaults.set(resolution.rawValue, forKey: Keys.iconResolution)
        }
    }

    @Published var saveOriginalPNG: Bool {
        didSet {
            defaults.set(saveOriginalPNG, forKey: Keys.saveOriginalPNG)
            if saveOriginalPNG {
                saveAsRounded = false
                saveAsSlightlyRounded = false
                useCustomCornerRadius = false
            }
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        saveAsRounded = defaults.bool(forKey: Keys.saveAsRounded)
        saveAsSlightlyRounded = defaults.bool(forKey: Keys.saveAsSlightlyRounded)
        useCustomCornerRadius = defaults.bool(forKey: Keys.useCustomCornerRadius)
        customCornerRadiusRatio = defaults.object(forKey: Keys.customCornerRadiusRatio) as? Double ?? 0.22
        saveOriginalPNG = defaults.bool(forKey: Keys.saveOriginalPNG)
        resolution = defaults.string(forKey: Keys.iconResolution)
            .flatMap(IconResolution.init(rawValue:)) ?? .size1024
    }
}
