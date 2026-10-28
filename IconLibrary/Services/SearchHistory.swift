//
//  SearchHistory.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/23.
//

import Foundation

final class SearchHistory {
    static let shared = SearchHistory()

    private let defaultsKey = "SearchTermHistory"
    private let limit = 10

    private init() {}

    func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
    }

    func add(_ term: String) {
        var terms = load()
        terms.removeAll { $0 == term }
        terms.insert(term, at: 0)
        UserDefaults.standard.set(Array(terms.prefix(limit)), forKey: defaultsKey)
    }

    func removeAll() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
}
