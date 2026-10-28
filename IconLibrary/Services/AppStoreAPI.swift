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

    static func lookup(id: Int, country: String) async -> Result<AppItem, Error> {
        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        components?.queryItems = [
            URLQueryItem(name: "id", value: String(id)),
            URLQueryItem(name: "country", value: country)
        ]
        guard let url = components?.url else { return .failure(APIError.invalidURL) }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
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

private enum APIError: LocalizedError {
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
