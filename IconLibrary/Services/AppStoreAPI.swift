//
//  AppStoreAPI.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/21.
//

import UIKit

enum AppStoreAPI {
    static func search(term: String, country: String) async -> Result<[AppItem], Error> {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "entity", value: "software")
        ]
        guard let url = components?.url else { return .failure(APIError.invalidURL) }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return .success(try JSONDecoder().decode(Response<AppItem>.self, from: data).results)
        } catch {
            return .failure(error)
        }
    }

    /// Fetches one app. Apple's iTunes edge caches can briefly return stale data
    /// (e.g. right after a release), so a single response is not trusted: a second,
    /// cache-bypassing request is fired and the newer result wins.
    static func lookup(id: Int, country: String) async -> Result<AppItem, Error> {
        async let first = lookupOnce(id: id, country: country, cacheBusting: false)
        async let second = lookupOnce(id: id, country: country, cacheBusting: true)

        let results = await [first, second]

        let items = results.compactMap { result -> AppItem? in
            if case .success(let item) = result { return item }
            return nil
        }

        guard let freshest = items.max(by: { isOlder($0, than: $1) }) else {
            // No usable response — surface the failure that is not "not found" if possible.
            let failures = results.compactMap { result -> Error? in
                if case .failure(let error) = result { return error }
                return nil
            }
            return .failure(failures.first(where: { ($0 as? APIError) != .appNotFound }) ?? APIError.appNotFound)
        }
        return .success(freshest)
    }

    /// Ordering between two responses for the same app: later release date wins,
    /// falling back to a numeric version comparison when the date is missing.
    private static func isOlder(_ lhs: AppItem, than rhs: AppItem) -> Bool {
        let lhsDate = releaseDate(lhs)
        let rhsDate = releaseDate(rhs)
        if let lhsDate, let rhsDate, lhsDate != rhsDate {
            return lhsDate < rhsDate
        }
        let lhsVersion = lhs.details?.version ?? ""
        let rhsVersion = rhs.details?.version ?? ""
        return compareVersions(lhsVersion, rhsVersion) < 0
    }

    private static func releaseDate(_ item: AppItem) -> Date? {
        guard let raw = item.details?.currentVersionReleaseDate, !raw.isEmpty else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = parser.date(from: raw) { return date }
        parser.formatOptions = [.withInternetDateTime]
        return parser.date(from: raw)
    }

    /// Numeric component-wise comparison, e.g. "40.9.0" > "40.8.1".
    private static func compareVersions(_ lhs: String, _ rhs: String) -> Int {
        let left = lhs.split(separator: ".").map { Int($0) ?? 0 }
        let right = rhs.split(separator: ".").map { Int($0) ?? 0 }
        for index in 0..<max(left.count, right.count) {
            let l = index < left.count ? left[index] : 0
            let r = index < right.count ? right[index] : 0
            if l != r { return l < r ? -1 : 1 }
        }
        return 0
    }

    private static func lookupOnce(id: Int, country: String, cacheBusting: Bool) async -> Result<AppItem, Error> {
        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        var items = [
            URLQueryItem(name: "id", value: String(id)),
            URLQueryItem(name: "country", value: country)
        ]
        if cacheBusting {
            // `_` is ignored by the API but makes the URL unique, so a different
            // edge node / fresh cache entry is more likely to answer.
            items.append(URLQueryItem(name: "_", value: String(Int(Date().timeIntervalSince1970 * 1000))))
        }
        components?.queryItems = items
        guard let url = components?.url else { return .failure(APIError.invalidURL) }

        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            let (data, _) = try await URLSession.shared.data(for: request)
            guard var item = try JSONDecoder().decode(Response<AppItem>.self, from: data).results.first,
                  item.details != nil else {
                return .failure(APIError.appNotFound)
            }
            item.countryCode = country
            return .success(item)
        } catch {
            return .failure(error)
        }
    }

    static func lookup(id: Int, inAnyOf countries: [String]) async -> Result<AppItem, Error> {
        var lastFailure: Error = APIError.appNotFound
        for country in countries.uniqued() {
            switch await lookup(id: id, country: country) {
            case .success(let item):
                return .success(item)
            case .failure(let error):
                lastFailure = error
            }
        }
        return .failure(lastFailure)
    }

    static func data(from url: URL?) async -> Data? {
        guard let url else { return nil }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200 ? data : nil
        } catch {
            return nil
        }
    }

    static func image(from url: URL?) async -> UIImage? {
        await data(from: url).flatMap(UIImage.init(data:))
    }
}

private struct Response<Item: Decodable>: Decodable {
    let results: [Item]
}

private enum APIError: LocalizedError, Equatable {
    case invalidURL
    case appNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL: return .localized("url_invalid")
        case .appNotFound: return .localized("app_not_found")
        }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
