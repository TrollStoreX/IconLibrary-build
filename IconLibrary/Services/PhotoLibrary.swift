//
//  PhotoLibrary.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/23.
//

import Photos
import UIKit
import UniformTypeIdentifiers

enum PhotoLibrary {
    static func save(_ image: UIImage, successMessage key: String) async -> SaveOutcome {
        guard let data = image.pngData() else { return .failure(SaveError.encodingFailed) }
        return await save(data, successMessage: key)
    }

    static func save(_ pngData: Data, successMessage key: String) async -> SaveOutcome {
        do {
            try await write(pngData)
            return .success(key)
        } catch {
            return .failure(error)
        }
    }

    private static func write(_ pngData: Data) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { throw SaveError.permissionDenied }

        let options = PHAssetResourceCreationOptions()
        options.uniformTypeIdentifier = UTType.png.identifier
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: pngData, options: options)
        }
    }
}

private enum SaveError: LocalizedError {
    case permissionDenied
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied: return .localized("permission_denied_message")
        case .encodingFailed: return .localized("image_data_error")
        }
    }
}
