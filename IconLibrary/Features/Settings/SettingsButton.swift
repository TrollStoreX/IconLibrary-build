//
//  SettingsButton.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/29.
//

import SwiftUI

extension View {
    func settingsButton() -> some View {
        modifier(SettingsButton())
    }
}

private struct SettingsButton: ViewModifier {
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = true
                    } label: {
                        Label("settings", systemImage: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                SettingsView()
            }
    }
}
