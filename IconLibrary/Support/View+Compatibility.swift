//
//  View+Compatibility.swift
//  IconLibrary
//
//  Created by iosdump on 2026/9/30.
//

import SwiftUI

struct NavigationContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack { content }
        } else {
            NavigationView { content }
                .navigationViewStyle(.stack)
        }
    }
}

struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .close) { dismiss() }
        } else {
            Button("done") { dismiss() }
        }
    }
}

extension View {
    @ViewBuilder
    func searchField(text: Binding<String>, prompt: LocalizedStringKey) -> some View {
        if #available(iOS 26.0, *) {
            searchable(text: text, prompt: Text(prompt))
        } else {
            searchable(text: text, placement: .navigationBarDrawer(displayMode: .always), prompt: Text(prompt))
        }
    }

    @ViewBuilder
    func navigationDestination<Item: Hashable, Destination: View>(
        unwrapping item: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        let isPresented = Binding(
            get: { item.wrappedValue != nil },
            set: { if !$0 { item.wrappedValue = nil } }
        )
        if #available(iOS 17.0, *) {
            navigationDestination(item: item, destination: destination)
        } else if #available(iOS 16.0, *) {
            navigationDestination(isPresented: isPresented) {
                if let value = item.wrappedValue {
                    destination(value)
                }
            }
        } else {
            background(
                NavigationLink(destination: item.wrappedValue.map(destination), isActive: isPresented) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }

    @ViewBuilder
    func hidesListBackground() -> some View {
        if #available(iOS 16.0, *) {
            scrollContentBackground(.hidden)
        } else {
            self
        }
    }

    @ViewBuilder
    func symbolReplaceTransition() -> some View {
        if #available(iOS 17.0, *) {
            contentTransition(.symbolEffect(.replace))
        } else {
            self
        }
    }

    func adaptsToReduceMotion() -> some View {
        modifier(ReduceMotionAdapter())
    }
}

private struct ReduceMotionAdapter: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.transaction { transaction in
            guard reduceMotion, transaction.animation != nil else { return }
            transaction.animation = .easeInOut(duration: 0.2)
        }
    }
}
