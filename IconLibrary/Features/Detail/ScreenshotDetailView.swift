//
//  ScreenshotDetailView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/28.
//

import SwiftUI

struct ScreenshotDetailView: View {
    let imageURL: URL?

    @State private var isSaving = false
    @State private var saveOutcome: SaveOutcome?

    var body: some View {
        AsyncImage(url: imageURL, transaction: Transaction(animation: .easeOut(duration: 0.35))) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onLongPressGesture(perform: saveScreenshot)
                    .transition(.opacity)
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            default:
                LoadingIndicator()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .saveFeedback(saveOutcome)
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            FloatingSaveButton(titleKey: "save_screenshot", systemImage: "square.and.arrow.down", isWorking: isSaving) {
                saveScreenshot()
            }
        }
        .navigationTitle("navigation_title_screenshot")
        .navigationBarTitleDisplayMode(.inline)
        .darkNavigationBar()
    }

    private func saveScreenshot() {
        guard !isSaving else { return }
        guard let imageURL else {
            saveOutcome = .failure("screenshot_url_invalid")
            return
        }

        isSaving = true
        Task {
            if let image = await AppStoreAPI.image(from: imageURL) {
                saveOutcome = await PhotoLibrary.save(image, successMessage: "save_success_message_screenshot")
            } else {
                saveOutcome = .failure("download_fail_message_screenshot")
            }
            isSaving = false
        }
    }
}

private extension View {
    @ViewBuilder
    func darkNavigationBar() -> some View {
        if #available(iOS 16.0, *) {
            toolbarBackground(Color.black, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        } else {
            self
        }
    }
}
