//
//  AppDetailView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/27.
//

import SwiftUI

struct AppDetailView: View {
    let appItem: AppItem
    let countryCode: String

    @Environment(\.openURL) private var openURL
    @State private var details: AppDetails?
    @State private var storeCountry: String?
    @State private var loadFailed = false
    @State private var hasRefreshed = false
    @State private var isSaving = false
    @State private var saveOutcome: SaveOutcome?

    private enum Phase {
        case loading, failed, loaded
    }

    private var phase: Phase {
        if details != nil { return .loaded }
        return loadFailed ? .failed : .loading
    }

    init(appItem: AppItem, countryCode: String) {
        self.appItem = appItem
        self.countryCode = countryCode
        _details = State(initialValue: appItem.details)
    }

    var body: some View {
        ZStack {
            switch phase {
            case .loading:
                StatusLayout(anchorHeight: LoadingIndicator.size) {
                    LoadingIndicator()
                }
            case .failed:
                EmptyStateView(
                    systemImage: "exclamationmark.triangle",
                    title: Text("detail_load_failed"),
                    retry: { Task { await refreshDetails() } }
                )
            case .loaded:
                if let details {
                    content(for: details)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .animation(.appSpring, value: phase)
        .saveFeedback(saveOutcome)
        .navigationTitle(appItem.trackName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: openInAppStore) {
                    Label("open_in_app_store", systemImage: "arrow.up.forward.app")
                }
            }
        }
        .task {
            guard !hasRefreshed else { return }
            hasRefreshed = true
            await refreshDetails()
        }
    }

    private func content(for details: AppDetails) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                DetailHeader(iconURL: appItem.artworkURL, details: details)
                    .padding(.horizontal)

                DetailSection(title: "section_header_information") {
                    CopyableGroup(items: [
                        CopyableItem(label: "label_bundle_id", value: details.bundleId),
                        CopyableItem(label: "label_track_id", value: String(details.trackId)),
                        CopyableItem(label: "label_appstore_link", value: details.appStoreURL),
                        CopyableItem(label: "label_min_os", value: "iOS \(details.minimumOsVersion)")
                    ])
                }

                DetailSection(title: "section_header_current_version") {
                    CopyableGroup(items: versionItems(for: details))
                }

                if !details.screenshotUrls.isEmpty {
                    DetailSection(title: "section_header_screenshots") {
                        ScreenshotStrip(urls: details.screenshotUrls)
                    }
                }

                DetailSection(title: "section_header_description") {
                    Text(details.description)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: Theme.Corner.card, style: .continuous))
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            FloatingSaveButton(titleKey: "save_icon", systemImage: "square.and.arrow.down", isWorking: isSaving) {
                saveIcon()
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func versionItems(for details: AppDetails) -> [CopyableItem] {
        var items = [CopyableItem(label: "label_version", value: details.version)]
        if let updated = details.formattedUpdateDate {
            items.append(CopyableItem(label: "label_update_date", value: updated))
        }
        if let notes = details.releaseNotes, !notes.isEmpty {
            items.append(CopyableItem(label: "label_release_notes", value: notes))
        }
        return items
    }

    private func refreshDetails() async {
        loadFailed = false
        let countries = [appItem.countryCode, countryCode, "US"].compactMap { $0 }

        switch await AppStoreAPI.lookup(id: appItem.trackId, inAnyOf: countries) {
        case .success(let item):
            guard let fresh = item.details else { return }
            let country = item.countryCode ?? countryCode
            details = fresh
            storeCountry = country
            DownloadHistory.shared.updateDetails(fresh, country: country, for: appItem.trackId)
        case .failure:
            loadFailed = details == nil
        }
    }

    private func saveIcon() {
        guard !isSaving else { return }
        isSaving = true

        var item = appItem
        item.countryCode = storeCountry ?? appItem.countryCode ?? countryCode
        item.details = details

        Task {
            let outcome = await IconSaver.save(item)
            if outcome.succeeded {
                DownloadHistory.shared.add(item)
            }
            isSaving = false
            saveOutcome = outcome
        }
    }

    private func openInAppStore() {
        guard let appURL = URL(string: "itms-apps://apps.apple.com/app/id\(appItem.trackId)") else { return }
        openURL(appURL) { accepted in
            guard !accepted, let webURL = URL(string: "https://apps.apple.com/app/id\(appItem.trackId)") else { return }
            openURL(webURL)
        }
    }
}

private struct DetailHeader: View {
    let iconURL: URL?
    let details: AppDetails

    @ScaledMetric(relativeTo: .title) private var iconSize: CGFloat = 96

    var body: some View {
        HStack(spacing: 16) {
            AppIconView(url: iconURL, size: iconSize)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 6) {
                Text(details.trackName)
                    .font(.rounded(.title2))
                    .lineLimit(3)
                Text(details.artistName)
                    .font(.subheadline.weight(.medium))
                    .opacity(0.8)
            }
            .foregroundColor(Theme.accentLabel)

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Theme.accentFill, in: RoundedRectangle(cornerRadius: Theme.Corner.loose, style: .continuous))
    }
}

private struct DetailSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.rounded(.title3))
                .padding(.horizontal)
            content
        }
    }
}

private struct CopyableItem {
    let label: LocalizedStringKey
    let value: String
}

private struct CopyableGroup: View {
    let items: [CopyableItem]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(items.indices, id: \.self) { index in
                CopyableRow(item: items[index], position: RowPosition(index: index, count: items.count))
            }
        }
        .padding(.horizontal)
    }
}

private struct CopyableRow: View {
    let item: CopyableItem
    let position: RowPosition

    @State private var didCopy = false

    var body: some View {
        Button(action: copy) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.label)
                        .font(.caption.weight(.medium))
                        .foregroundColor(Theme.secondaryText)
                    Text(item.value)
                        .font(.callout)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                    .symbolReplaceTransition()
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(didCopy ? Theme.accentLabel : Theme.secondaryText)
                    .frame(width: 36, height: 36)
                    .background(didCopy ? Theme.accentFill : Theme.mutedFill, in: Circle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(GroupedRowButtonStyle(position: position))
    }

    private func copy() {
        UIPasteboard.general.string = item.value
        Haptics.selection()
        withAnimation(.quickSpring) { didCopy = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.quickSpring) { didCopy = false }
        }
    }
}

private struct ScreenshotStrip: View {
    let urls: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(urls, id: \.self) { url in
                    NavigationLink(destination: ScreenshotDetailView(imageURL: URL(string: url))) {
                        Screenshot(url: URL(string: url))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct Screenshot: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.35))) { phase in
            if case .success(let image) = phase {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .transition(.opacity)
            } else {
                ShimmerPlaceholder()
                    .aspectRatio(9 / 19.5, contentMode: .fit)
            }
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Corner.card, style: .continuous))
    }
}
