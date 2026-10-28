//
//  SearchView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/24.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isShowingRegions = false
    @State private var isConfirmingClear = false

    private enum Phase {
        case loading, recentSearches, results, message, idle
    }

    private var phase: Phase {
        if viewModel.isLoading { return .loading }
        if viewModel.searchTerm.isEmpty { return .recentSearches }
        if !viewModel.searchResults.isEmpty { return .results }
        return viewModel.presentedApp == nil ? .message : .idle
    }

    var body: some View {
        NavigationContainer {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.background)
                .animation(.appSpring, value: phase)
                .saveFeedback(viewModel.saveOutcome)
                .navigationTitle("navigation_title_icon_library")
                .settingsButton()
                .toolbar { regionButton }
                .navigationDestination(unwrapping: $viewModel.presentedApp) { item in
                    AppDetailView(appItem: item, countryCode: item.countryCode ?? viewModel.selectedCountryCode)
                }
        }
        .searchField(text: $viewModel.searchTerm, prompt: "search_placeholder")
        .onSubmit(of: .search) { viewModel.performSearch() }
        .sheet(isPresented: $isShowingRegions) {
            CountryListView(selectedCountryCode: $viewModel.selectedCountryCode)
        }
        .alert("clear_search_history_confirmation", isPresented: $isConfirmingClear) {
            Button("clear", role: .destructive) {
                withAnimation(.appSpring) { viewModel.clearRecentSearches() }
            }
            Button("cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loading:
            StatusLayout(anchorHeight: LoadingIndicator.size) {
                VStack(spacing: 20) {
                    LoadingIndicator()
                    Text("searching")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                }
            }
        case .recentSearches:
            RecentSearchesView(
                terms: viewModel.recentSearches,
                onSelect: { viewModel.search(forRecentTerm: $0) },
                onClear: { isConfirmingClear = true }
            )
        case .results:
            resultsList
        case .message:
            EmptyStateView(systemImage: "magnifyingglass", message: Text(viewModel.statusMessage))
        case .idle:
            Color.clear
        }
    }

    private var resultsList: some View {
        List {
            ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, item in
                AppListRow(
                    item: item,
                    subtitle: item.artistName,
                    position: RowPosition(index: index, count: viewModel.searchResults.count),
                    isSaving: viewModel.savingIDs.contains(item.id),
                    onOpen: { viewModel.presentedApp = item },
                    onSave: { viewModel.saveIcon(for: item) }
                )
            }
        }
        .cardListStyle()
        .refreshable { await viewModel.refreshSearchResults() }
    }

    private var regionButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if let country = Country.matching(viewModel.selectedCountryCode) {
                Button {
                    isShowingRegions = true
                } label: {
                    RegionBadge(country: country)
                }
                .accessibilityLabel(Text(LocalizedStringKey(country.nameKey)))
            }
        }
    }
}

private struct RecentSearchesView: View {
    let terms: [String]
    let onSelect: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        if terms.isEmpty {
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: Text("no_search_history"),
                message: Text("initial_search_message")
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("search_history")
                            .font(.rounded(.title3))
                        Spacer()
                        Button(action: onClear) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(RoundIconButtonStyle())
                        .accessibilityLabel(Text("clear"))
                    }

                    FlowStack {
                        ForEach(terms, id: \.self) { term in
                            Button {
                                onSelect(term)
                            } label: {
                                Label(term, systemImage: "clock.arrow.circlepath")
                            }
                            .buttonStyle(TagButtonStyle())
                        }
                    }
                }
                .padding()
            }
        }
    }
}

private struct RegionBadge: View {
    let country: Country

    var body: some View {
        HStack(spacing: 4) {
            Text(country.flag)
            Text(country.code)
        }
        .font(.subheadline.weight(.semibold))
        .modifier(RegionBadgeBackground())
    }
}

private struct RegionBadgeBackground: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .foregroundColor(Theme.highlightLabel)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Theme.highlightFill, in: Capsule())
        }
    }
}
