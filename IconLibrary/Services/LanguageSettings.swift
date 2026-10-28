//
//  LanguageSettings.swift
//  IconLibrary
//
//  Created by iosdump on 2026/10/1.
//

import Combine
import Foundation

enum Language: String, CaseIterable {
    case chinese = "zh-Hans"
    case english = "en"
    case vietnamese = "vi"

    fileprivate static let storageKey = "selectedLanguage"

    static var saved: Language {
        UserDefaults.standard.string(forKey: storageKey).flatMap(Language.init(rawValue:)) ?? .chinese
    }

    var displayName: String {
        switch self {
        case .chinese: return "简体中文"
        case .english: return "English"
        case .vietnamese: return "Tiếng Việt"
        }
    }

    fileprivate var bundle: Bundle {
        Bundle.main.path(forResource: rawValue, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .main
    }
}

@MainActor
final class LanguageSettings: ObservableObject {
    static let shared = LanguageSettings()

    @Published var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Language.storageKey)
        }
    }

    private init() {
        language = .saved
    }
}

extension String {
    static func localized(_ key: String) -> String {
        Language.saved.bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
