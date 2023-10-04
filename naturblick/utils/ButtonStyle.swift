//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ConfirmFullWidthButton: ButtonStyle {
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

struct AuxiliaryOnSecondaryButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.nbButton)
            .padding(.defaultPadding)
            .foregroundStyle(Color.onSecondaryHighEmphasis)
            .border(Color.onSecondaryMinimumEmphasis)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
    }
}

struct DestructiveFullWidthButton: ButtonStyle {
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
