//
//  Appearance.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/22.
//

import SwiftUI
import UIKit

@MainActor
enum Appearance {
    static func configure() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.largeTitleTextAttributes = [.font: UIFont.rounded(.largeTitle, weight: .bold)]
        navigationBar.titleTextAttributes = [.font: UIFont.rounded(.headline, weight: .semibold)]

        if #unavailable(iOS 26.0) {
            let tabBar = UITabBarAppearance()
            tabBar.configureWithOpaqueBackground()
            tabBar.backgroundColor = UIColor(Theme.cardBackground)
            tabBar.shadowColor = .clear
            UITabBar.appearance().standardAppearance = tabBar
            UITabBar.appearance().scrollEdgeAppearance = tabBar
        }

        if #unavailable(iOS 16.0) {
            UITableView.appearance().backgroundColor = .clear
        }
    }
}
