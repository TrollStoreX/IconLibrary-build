//
//  SaveFeedback.swift
//  IconLibrary
//
//  Created by iosdump on 2026/10/3.
//

import SwiftUI

struct SaveOutcome: Equatable {
    let id = UUID()
    let succeeded: Bool
    let message: String

    static func success(_ key: String) -> SaveOutcome {
        SaveOutcome(succeeded: true, message: .localized(key))
    }

    static func failure(_ key: String) -> SaveOutcome {
        SaveOutcome(succeeded: false, message: .localized(key))
    }

    static func failure(_ error: Error) -> SaveOutcome {
        SaveOutcome(succeeded: false, message: String(format: .localized("save_fail_message"), error.localizedDescription))
    }
}

extension View {
    func saveFeedback(_ outcome: SaveOutcome?) -> some View {
        modifier(SaveFeedbackPresenter(outcome: outcome))
    }
}

private struct SaveFeedbackPresenter: ViewModifier {
    let outcome: SaveOutcome?

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pending: SaveOutcome?
    @State private var visible: SaveOutcome?
    @State private var dismissal: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let visible {
                    Toast(outcome: visible)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .onTapGesture(perform: hide)
                        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                        .id(visible.id)
                }
            }
            .onChange(of: outcome) { newValue in
                guard let newValue else { return }
                pending = newValue
                presentPendingIfActive()
            }
            .onChange(of: scenePhase) { _ in
                presentPendingIfActive()
            }
            .onDisappear { dismissal?.cancel() }
    }

    private func presentPendingIfActive() {
        guard scenePhase == .active, let outcome = pending else { return }
        pending = nil
        Haptics.notify(outcome.succeeded ? .success : .error)
        UIAccessibility.post(notification: .announcement, argument: outcome.message)
        withAnimation(.appSpring) { visible = outcome }

        dismissal?.cancel()
        dismissal = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            hide()
        }
    }

    private func hide() {
        dismissal?.cancel()
        withAnimation(.appSpring) { visible = nil }
    }
}

private struct Toast: View {
    let outcome: SaveOutcome

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: outcome.succeeded ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundColor(outcome.succeeded ? Theme.toastSuccess : Theme.toastError)
            Text(outcome.message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Theme.toastText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.toastBackground, in: RoundedRectangle(cornerRadius: Theme.Corner.regular, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}
