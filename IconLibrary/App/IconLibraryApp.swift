//
//  IconLibraryApp.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/20.
//

import SwiftUI

@main
struct IconLibraryApp: App {
    @StateObject private var languageSettings = LanguageSettings.shared

    init() {
        Appearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.locale, Locale(identifier: languageSettings.language.rawValue))
                .id(languageSettings.language)
        }
    }
}
