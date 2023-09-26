//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ConfirmButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.nbButton)
            .padding(.defaultPadding)
            .frame(maxWidth: .infinity)
            .background(Color.onPrimaryButtonPrimary)
            .foregroundStyle(Color.onPrimaryHighEmphasis)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
    }
}

struct DestructiveButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.nbButton)
            .padding(.defaultPadding)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.onSecondarywarning)
            .border(Color.onSecondarywarning)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
    }
}
