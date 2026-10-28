//
//  IconSaver.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/23.
//

import UIKit

@MainActor
enum IconSaver {
    static func save(_ item: AppItem) async -> SaveOutcome {
        let settings = IconSettings.shared
        let savesOriginal = settings.saveOriginalPNG
        let resolution = savesOriginal ? IconResolution.size1024 : settings.resolution

        guard let data = await AppStoreAPI.data(from: item.iconURL(for: resolution)) else {
            return .failure(savesOriginal ? "download_fail_message_original" : "download_fail_message_icon")
        }
        if savesOriginal {
            return await PhotoLibrary.save(data, successMessage: "save_success_message_original")
        }

        guard let image = UIImage(data: data) else { return .failure("image_data_error") }
        guard let cornerRadius = cornerRadius(forWidth: image.size.width, settings: settings) else {
            return await PhotoLibrary.save(data, successMessage: "save_success_message_icon")
        }
        return await PhotoLibrary.save(image.withCornerRadius(cornerRadius), successMessage: "save_success_message_icon")
    }

    private static func cornerRadius(forWidth width: CGFloat, settings: IconSettings) -> CGFloat? {
        if settings.saveAsRounded {
            return width / 2
        }
        if settings.saveAsSlightlyRounded {
            return width * 0.08
        }
        if settings.useCustomCornerRadius {
            return width * settings.customCornerRadiusRatio
        }
        return nil
    }
}
