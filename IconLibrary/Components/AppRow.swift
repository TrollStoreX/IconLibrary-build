//
//  AppRow.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/25.
//

import SwiftUI

struct AppIconView: View {
    let url: URL?
    let size: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous)
    }

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.35))) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            case .failure:
                Image(systemName: "app.dashed")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(Theme.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.mutedFill)
            default:
                ShimmerPlaceholder()
            }
        }
        .frame(width: size, height: size)
        .clipShape(shape)
        .overlay(shape.strokeBorder(Theme.separator.opacity(0.6), lineWidth: 0.5))
        .accessibilityHidden(true)
    }
}

struct ShimmerPlaceholder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            Theme.mutedFill
        } else {
            TimelineView(.animation) { context in
                let progress = context.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 1.4) / 1.4
                GeometryReader { proxy in
                    let width = proxy.size.width
                    Theme.mutedFill
                        .overlay(
                            LinearGradient(
                                colors: [.clear, Theme.shimmer.opacity(0.55), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: width * 0.8)
                            .offset(x: -width + progress * width * 2)
                        )
                }
            }
        }
    }
}

struct AppListRow: View {
    let item: AppItem
    let subtitle: String?
    let position: RowPosition
    var isSaving = false
    let onOpen: () -> Void
    let onSave: () -> Void
    var onDelete: (() -> Void)?

    var body: some View {
        Button(action: onOpen) {
            AppRowContent(item: item, subtitle: subtitle, isSaving: isSaving, onSave: onSave)
        }
        .buttonStyle(GroupedRowButtonStyle(position: position))
        .contentShape(.contextMenuPreview, position.shape)
        .contextMenu {
            saveButton
            if let onDelete {
                deleteButton(onDelete)
            }
        }
        .swipeActions(edge: .leading) {
            saveButton.tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            if let onDelete {
                deleteButton(onDelete)
            }
        }
        .listRowInsets(EdgeInsets(top: 1, leading: 16, bottom: 1, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private var saveButton: some View {
        Button(action: onSave) {
            Label("save_icon", systemImage: "square.and.arrow.down")
        }
        .disabled(isSaving)
    }

    private func deleteButton(_ action: @escaping () -> Void) -> some View {
        Button(role: .destructive, action: action) {
            Label("delete", systemImage: "trash")
        }
    }
}

private struct AppRowContent: View {
    let item: AppItem
    let subtitle: String?
    let isSaving: Bool
    let onSave: () -> Void

    @ScaledMetric(relativeTo: .headline) private var iconSize: CGFloat = 56

    var body: some View {
        HStack(spacing: 14) {
            AppIconView(url: item.artworkURL, size: iconSize)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.trackName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Button(action: onSave) {
                ZStack {
                    Image(systemName: "square.and.arrow.down")
                        .opacity(isSaving ? 0 : 1)
                    if isSaving {
                        ProgressView()
                            .tint(Theme.highlightLabel)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.quickSpring, value: isSaving)
            }
            .buttonStyle(RoundIconButtonStyle())
            .disabled(isSaving)
            .accessibilityLabel(Text("save_icon"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

extension View {
    func cardListStyle() -> some View {
        listStyle(.plain)
            .hidesListBackground()
            .background(Theme.background)
    }
}
