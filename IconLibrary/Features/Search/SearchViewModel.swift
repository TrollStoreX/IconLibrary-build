//
//  SearchViewModel.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/24.
//

import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchTerm = ""
    @Published var selectedCountryCode = Country.preferredCode {
        didSet { Country.preferredCode = selectedCountryCode }
    }
    @Published var presentedApp: AppItem?
    @Published private(set) var searchResults: [AppItem] = []
    @Published private(set) var recentSearches: [String] = []
    @Published private(set) var isLoading = false
    @Published private(set) var statusMessage = String.localized("initial_search_message")
    @Published private(set) var savingIDs: Set<Int> = []
    @Published private(set) var saveOutcome: SaveOutcome?

    private var cancellables = Set<AnyCancellable>()

    init() {
        recentSearches = SearchHistory.shared.load()

        $searchTerm
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .filter(\.isEmpty)
            .sink { [weak self] _ in self?.clearResults() }
            .store(in: &cancellables)
    }

    func performSearch() {
        let term = searchTerm.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return }

        let link = AppStoreLink(term)
        if link == nil {
            SearchHistory.shared.add(term)
            recentSearches = SearchHistory.shared.load()
        }

        isLoading = true
        searchResults = []
        statusMessage = .localized("searching")

        Task {
            if let link {
                await lookUp(id: link.id, country: link.country ?? selectedCountryCode)
            } else {
                await search(term)
            }
        }
    }

    func search(forRecentTerm term: String) {
        searchTerm = term
        performSearch()
    }

    func clearRecentSearches() {
        SearchHistory.shared.removeAll()
        recentSearches = []
    }

    func saveIcon(for item: AppItem) {
        guard !savingIDs.contains(item.id) else { return }
        savingIDs.insert(item.id)

        var item = item
        item.countryCode = selectedCountryCode

        Task {
            let outcome = await IconSaver.save(item)
            if outcome.succeeded {
                DownloadHistory.shared.add(item)
            }
            savingIDs.remove(item.id)
            saveOutcome = outcome
        }
    }

    private func search(_ term: String) async {
        let result = await AppStoreAPI.search(term: term, country: selectedCountryCode)
        isLoading = false

        switch result {
        case .success(let items) where items.isEmpty:
            let countryName = Country.matching(selectedCountryCode)?.localizedName ?? selectedCountryCode
            statusMessage = String(format: .localized("search_no_results_message"), countryName, term)
        case .success(let items):
            searchResults = items
            statusMessage = ""
        case .failure(let error):
            statusMessage = String(format: .localized("search_error_message"), error.localizedDescription)
        }
    }

    private func lookUp(id: Int, country: String) async {
        let result = await AppStoreAPI.lookup(id: id, country: country)
        isLoading = false

        switch result {
        case .success(let item):
            presentedApp = item
            statusMessage = .localized("url_found_message")
        case .failure(let error):
            statusMessage = String(format: .localized("url_failure_message"), error.localizedDescription)
        }
    }

    private func clearResults() {
        searchResults = []
        statusMessage = .localized("initial_search_message")
    }
}
