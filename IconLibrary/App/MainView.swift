//
//  MainView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/21.
//

import SwiftUI

struct MainView: View {
    private enum Destination: Hashable {
        case search
        case history
    }

    @State private var selection = Destination.search

    var body: some View {
        tabs.adaptsToReduceMotion()
    }

    @ViewBuilder
    private var tabs: some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $selection) {
                Tab("search", systemImage: "magnifyingglass", value: Destination.search, role: .search) {
                    SearchView()
                }
                Tab(value: Destination.history) {
                    HistoryView()
                } label: {
                    tabLabel("history", systemImage: "clock")
                }
            }
        } else {
            TabView(selection: $selection) {
                SearchView()
                    .tabItem { tabLabel("search", systemImage: "magnifyingglass") }
                    .tag(Destination.search)
                HistoryView()
                    .tabItem { tabLabel("history", systemImage: "clock") }
                    .tag(Destination.history)
            }
        }
    }

    private func tabLabel(_ titleKey: LocalizedStringKey, systemImage: String) -> some View {
        Label(titleKey, systemImage: systemImage)
            .environment(\.symbolVariants, .none)
    }
}
