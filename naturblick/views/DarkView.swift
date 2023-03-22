//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct DarkView<Content: View>: View {

    @ViewBuilder let content: () -> Content

    private let color = Color.primary500

    var body: some View {
        ZStack {
            Color.primary500.ignoresSafeArea()
            content()
        }
    }
}
