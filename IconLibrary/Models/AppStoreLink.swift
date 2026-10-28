//
//  AppStoreLink.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/21.
//

import Foundation

struct AppStoreLink {
    let id: Int
    let country: String?

    private static let regex = try? NSRegularExpression(
        pattern: #"(?:apps|itunes)\.apple\.com/(?:([a-zA-Z]{2})/)?app(?:/.+)?/id([0-9]+)"#,
        options: .caseInsensitive
    )

    init?(_ string: String) {
        let range = NSRange(string.startIndex..., in: string)
        guard let match = Self.regex?.firstMatch(in: string, range: range),
              let idRange = Range(match.range(at: 2), in: string),
              let id = Int(string[idRange]) else {
            return nil
        }
        self.id = id
        country = Range(match.range(at: 1), in: string).map { string[$0].uppercased() }
    }
}
