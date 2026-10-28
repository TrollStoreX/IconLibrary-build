//
//  SettingsView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/29.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = IconSettings.shared
    @ObservedObject private var languageSettings = LanguageSettings.shared

    private let aboutURL = URL(string: "https://t.me/iosdumpzzz")!
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    var body: some View {
        NavigationContainer {
            Form {
                saveOptionsSection
                languageSection
                aboutSection
            }
            .hidesListBackground()
            .background(Theme.background)
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CloseButton()
                }
            }
        }
        .adaptsToReduceMotion()
    }

    private var saveOptionsSection: some View {
        Section {
            Toggle("toggle_save_original_png", isOn: $settings.saveOriginalPNG.animation(.appSpring))
                .listRowBackground(Theme.cardBackground)

            Group {
                Toggle("toggle_save_as_rounded", isOn: $settings.saveAsRounded.animation(.appSpring))
                Toggle("toggle_save_as_slightly_rounded", isOn: $settings.saveAsSlightlyRounded.animation(.appSpring))
                Toggle("toggle_custom_corner_radius", isOn: $settings.useCustomCornerRadius.animation(.appSpring))
                if settings.useCustomCornerRadius {
                    CornerRadiusEditor(ratio: $settings.customCornerRadiusRatio)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("picker_label_resolution")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                    OptionPicker(selection: $settings.resolution, options: IconResolution.allCases) {
                        Text($0.rawValue)
                    }
                }
                .padding(.vertical, 6)
            }
            .disabled(settings.saveOriginalPNG)
            .opacity(settings.saveOriginalPNG ? 0.5 : 1)
            .listRowBackground(Theme.cardBackground)
        } header: {
            SectionHeader(title: "section_header_save_options")
        }
    }

    private var languageSection: some View {
        Section {
            ForEach(Language.allCases, id: \.self) { language in
                LanguageRow(language: language, isSelected: language == languageSettings.language) {
                    select(language)
                }
            }
            .listRowBackground(Theme.cardBackground)
        } header: {
            SectionHeader(title: "section_header_language")
        }
    }

    private var aboutSection: some View {
        Section {
            Link(destination: aboutURL) {
                HStack {
                    Label("about", systemImage: "info.circle")
                    Spacer()
                    Text(appVersion)
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(Theme.secondaryText)
                    Image(systemName: "arrow.up.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .listRowBackground(Theme.cardBackground)
        }
    }

    private func select(_ language: Language) {
        guard language != languageSettings.language else { return }
        Haptics.selection()
        withAnimation(.easeInOut(duration: 0.3)) {
            languageSettings.language = language
        }
    }
}

private struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(language.displayName)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.accentColor)
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 0.5)
            }
            .contentShape(Rectangle())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct CornerRadiusEditor: View {
    @Binding var ratio: Double

    @ScaledMetric(relativeTo: .largeTitle) private var previewSize: CGFloat = 112
    @State private var liveRatio: Double
    @State private var isDragging = false

    init(ratio: Binding<Double>) {
        _ratio = ratio
        _liveRatio = State(initialValue: ratio.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 18) {
            Image("IconPreview")
                .resizable()
                .scaledToFit()
                .frame(width: previewSize, height: previewSize)
                .clipShape(RoundedRectangle(cornerRadius: previewSize * liveRatio, style: .continuous))
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 5)
                .accessibilityHidden(true)

            VStack(spacing: 6) {
                HStack {
                    Text("corner_radius_ratio")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                    Spacer()
                    Text(liveRatio, format: .percent.precision(.fractionLength(0)))
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                }
                Slider(value: $liveRatio, in: IconSettings.cornerRadiusRange) { editing in
                    isDragging = editing
                    if !editing {
                        ratio = liveRatio
                    }
                }
                .accessibilityLabel(Text("corner_radius_ratio"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Theme.mutedFill, in: RoundedRectangle(cornerRadius: Theme.Corner.card, style: .continuous))
        .padding(.vertical, 6)
        .onChange(of: liveRatio) { newValue in
            if !isDragging {
                ratio = newValue
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

private struct SectionHeader: View {
    let title: LocalizedStringKey

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.accentColor)
            .textCase(nil)
    }
}
