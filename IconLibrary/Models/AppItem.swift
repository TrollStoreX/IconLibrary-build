//
//  AppItem.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/20.
//

import Foundation

struct AppItem: Codable, Identifiable, Hashable {
    let trackId: Int
    let trackName: String
    let artistName: String?
    let artworkUrl100: String
    let artworkUrl512: String
    var countryCode: String?
    var details: AppDetails?

    var id: Int { trackId }

    private enum CodingKeys: String, CodingKey {
        case trackId, trackName, artistName, artworkUrl100, artworkUrl512, countryCode, details
    }

    var artworkURL: URL? {
        URL(string: artworkUrl512) ?? URL(string: artworkUrl100)
    }

    func iconURL(for resolution: IconResolution) -> URL? {
        artworkURL?.deletingLastPathComponent().appendingPathComponent("\(resolution.rawValue)bb.png")
    }
}

extension AppItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trackId = try container.decode(Int.self, forKey: .trackId)
        trackName = try container.decode(String.self, forKey: .trackName)
        artistName = try container.decodeIfPresent(String.self, forKey: .artistName)
        artworkUrl100 = try container.decode(String.self, forKey: .artworkUrl100)
        artworkUrl512 = try container.decode(String.self, forKey: .artworkUrl512)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)

        if let stored = try? container.decodeIfPresent(AppDetails.self, forKey: .details) {
            details = stored
        } else {
            details = try? AppDetails(from: decoder)
        }
    }
}

struct AppDetails: Codable, Hashable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let bundleId: String
    let description: String
    let version: String
    let releaseNotes: String?
    let screenshotUrls: [String]
    let minimumOsVersion: String
    /// When the current version was released (App Store "currentVersionReleaseDate").
    let currentVersionReleaseDate: String?

    /// Date and time string formatted for display in the UI, e.g. "2026-10-23 09:46:47".
    /// The App Store returns `currentVersionReleaseDate` as an ISO8601 timestamp with
    /// second-level precision (UTC), converted here to the device's local time zone.
    var formattedUpdateDate: String? {
        guard let raw = currentVersionReleaseDate, !raw.isEmpty else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = parser.date(from: raw)
        if date == nil {
            parser.formatOptions = [.withInternetDateTime]
            date = parser.date(from: raw)
        }
        guard let date else {
            // Not ISO8601 — hand back whatever the API gave us rather than nothing.
            return raw.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: "")
        }
        let display = DateFormatter()
        display.locale = Locale.current
        display.timeZone = .current
        display.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return display.string(from: date)
    }

    var appStoreURL: String {
        "https://apps.apple.com/app/id\(trackId)"
    }
}
