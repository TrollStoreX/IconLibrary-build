//
//  DownloadHistory.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/24.
//

import Foundation

final class DownloadHistory {
    static let shared = DownloadHistory()

    private let legacyDefaultsKey = "DownloadHistory"
    private let fileURL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("DownloadHistory.json")

    private init() {}

    func load() -> [AppItem] {
        guard let data = storedData() else { return [] }
        return (try? JSONDecoder().decode([AppItem].self, from: data)) ?? []
    }

    func add(_ item: AppItem) {
        var history = load()
        if let index = history.firstIndex(where: { $0.trackId == item.trackId }) {
            let existing = history[index]
            var merged = item
            merged.countryCode = item.countryCode ?? existing.countryCode
            merged.details = item.details ?? existing.details
            history[index] = merged
        } else {
            history.insert(item, at: 0)
        }
        save(history)
    }

    func updateDetails(_ details: AppDetails, country: String, for trackId: Int) {
        var history = load()
        guard let index = history.firstIndex(where: { $0.trackId == trackId }),
              history[index].details != details || history[index].countryCode != country else {
            return
        }
        history[index].details = details
        history[index].countryCode = country
        save(history)
    }

    func remove(_ item: AppItem) {
        var history = load()
        history.removeAll { $0.trackId == item.trackId }
        save(history)
    }

    func removeAll() {
        save([])
        let fileManager = FileManager.default
        let cachedFiles = (try? fileManager.contentsOfDirectory(at: fileManager.temporaryDirectory, includingPropertiesForKeys: nil)) ?? []
        for file in cachedFiles {
            try? fileManager.removeItem(at: file)
        }
    }

    private func storedData() -> Data? {
        if let data = try? Data(contentsOf: fileURL) {
            return data
        }
        return UserDefaults.standard.data(forKey: legacyDefaultsKey)
    }

    private func save(_ history: [AppItem]) {
        guard let data = try? JSONEncoder().encode(history) else { return }
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
            UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
        } catch {
            UserDefaults.standard.set(data, forKey: legacyDefaultsKey)
        }
    }
}
