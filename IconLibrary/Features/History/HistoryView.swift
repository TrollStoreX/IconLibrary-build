//
//  HistoryView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/28.
//

import SwiftUI

struct HistoryView: View {
    @State private var items: [AppItem] = []
    @State private var searchText = ""
    @State private var selectedItem: AppItem?
    @State private var isConfirmingClear = false
    @State private var savingIDs: Set<Int> = []
    @State private var saveOutcome: SaveOutcome?

    private var filteredItems: [AppItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.trackName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationContainer {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.background)
                .saveFeedback(saveOutcome)
                .onAppear { reload() }
                .navigationTitle("navigation_title_download_history")
                .settingsButton()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("clear") { isConfirmingClear = true }
                            .disabled(items.isEmpty)
                    }
                }
                .navigationDestination(unwrapping: $selectedItem) { item in
                    AppDetailView(appItem: item, countryCode: item.countryCode ?? Country.preferredCode)
                }
        }
        .searchField(text: $searchText, prompt: "history_search_placeholder")
        .alert("clear_history_confirmation", isPresented: $isConfirmingClear) {
            Button("clear", role: .destructive) { clearAll() }
            Button("cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var content: some View {
        if items.isEmpty {
            EmptyStateView(
                systemImage: "clock",
                title: Text("no_download_history"),
                message: Text("history_empty_message")
            )
        } else if filteredItems.isEmpty {
            EmptyStateView(systemImage: "magnifyingglass", title: Text("history_no_matches"))
        } else {
            List {
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    AppListRow(
                        item: item,
                        subtitle: subtitle(for: item),
                        position: RowPosition(index: index, count: filteredItems.count),
                        isSaving: savingIDs.contains(item.id),
                        onOpen: { selectedItem = item },
                        onSave: { save(item) },
                        onDelete: { delete(item) }
                    )
                }
            }
            .cardListStyle()
            .animation(.appSpring, value: filteredItems)
        }
    }

    private func subtitle(for item: AppItem) -> String? {
        let region = item.countryCode.flatMap(Country.matching).map { "\($0.flag) \($0.localizedName)" }
        let parts = [item.artistName, region].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private func reload() {
        items = DownloadHistory.shared.load()
    }

    private func save(_ item: AppItem) {
        guard !savingIDs.contains(item.id) else { return }
        savingIDs.insert(item.id)
        Task {
            let outcome = await IconSaver.save(item)
            savingIDs.remove(item.id)
            saveOutcome = outcome
        }
    }

    private func delete(_ item: AppItem) {
        DownloadHistory.shared.remove(item)
        withAnimation(.appSpring) { reload() }
    }

    private func clearAll() {
        DownloadHistory.shared.removeAll()
        withAnimation(.appSpring) { reload() }
    }
}
