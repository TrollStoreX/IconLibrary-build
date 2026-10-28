//
//  CountryListView.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/28.
//

import SwiftUI

struct CountryListView: View {
    @Binding var selectedCountryCode: String

    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredCountries: [Country] {
        guard !searchText.isEmpty else { return Country.all }
        return Country.all.filter {
            $0.localizedName.localizedCaseInsensitiveContains(searchText)
                || $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationContainer {
            List(filteredCountries) { country in
                CountryRow(country: country, isSelected: country.code == selectedCountryCode) {
                    Haptics.selection()
                    selectedCountryCode = country.code
                    dismiss()
                }
                .listRowInsets(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .cardListStyle()
            .navigationTitle("navigation_title_select_region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton()
                }
            }
        }
        .searchField(text: $searchText, prompt: "country_search_prompt")
        .adaptsToReduceMotion()
    }
}

private struct CountryRow: View {
    let country: Country
    let isSelected: Bool
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var flagSize: CGFloat = 44

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.title2)
                    .frame(width: flagSize, height: flagSize)
                    .background(isSelected ? Theme.background : Theme.mutedFill, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(country.nameKey))
                        .font(.body.weight(isSelected ? .semibold : .regular))
                    Text(country.code)
                        .font(.caption)
                        .foregroundColor(isSelected ? Theme.highlightLabel : Theme.secondaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundColor(isSelected ? Theme.highlightLabel : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Theme.highlightFill : Color.clear,
                        in: RoundedRectangle(cornerRadius: Theme.Corner.loose, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
