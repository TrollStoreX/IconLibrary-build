//
//  OptionPicker.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/27.
//

import SwiftUI

struct OptionPicker<Value: Hashable, Content: View>: View {
    @Binding var selection: Value
    let options: [Value]
    @ViewBuilder let label: (Value) -> Content

    @Namespace private var highlight

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                segment(for: option)
                if option != options.last {
                    Theme.separator.frame(width: 1)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Theme.separator))
    }

    private func segment(for option: Value) -> some View {
        let isSelected = option == selection
        return Button {
            guard !isSelected else { return }
            Haptics.selection()
            withAnimation(.quickSpring) { selection = option }
        } label: {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .transition(.scale.combined(with: .opacity))
                }
                label(option)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(isSelected ? Theme.highlightLabel : .primary)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background {
                if isSelected {
                    Theme.highlightFill
                        .matchedGeometryEffect(id: "selection", in: highlight)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
