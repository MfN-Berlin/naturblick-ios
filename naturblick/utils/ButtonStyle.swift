//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ConfirmFullWidthButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .frame(maxWidth: .infinity)
            .background(Color.onPrimaryButtonPrimary)
            .foregroundStyle(Color.onPrimaryHighEmphasis)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .nbShadow()
    }
}

struct ConfirmButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .background(Color.onPrimaryButtonPrimary)
            .foregroundStyle(Color.onPrimaryHighEmphasis)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .nbShadow()
    }
}

struct SecondaryOnSecondaryButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .foregroundStyle(Color.onPrimaryHighEmphasis)
            .background(Color.onSecondaryButtonSecondary)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .nbShadow()
    }
}

struct AuxiliaryOnSecondaryButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .foregroundStyle(Color.onSecondaryHighEmphasis)
            .border(Color.onSecondaryMinimumEmphasis)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .nbShadow()
    }
}

struct AuxiliaryOnSecondaryFullwidthButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.onSecondaryHighEmphasis)
            .border(Color.onSecondaryMinimumEmphasis)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .nbShadow()
    }
}

struct ButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(spacing: .halfPadding) {
            configuration.icon
            configuration.title
                .accessibilityFont(.nbButton)
        }
        .padding(.halfPadding)
    }
}

struct AuxiliaryOnPrimaryButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .labelStyle(ButtonLabelStyle())
            .foregroundStyle(Color.onPrimaryHighEmphasis)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .border(Color.onPrimaryMinimumEmphasis)
    }
}

struct ChangeSpeciesButton: ButtonStyle{
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.halfPadding)
            .foregroundStyle(Color.onSecondaryButtonPrimary)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .border(Color.onSecondaryLowEmphasis)
    }
}

struct DestructiveFullWidthButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.onSecondarywarning)
            .border(Color.onSecondarywarning)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .nbShadow()
    }
}

struct DestructiveButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .foregroundStyle(Color.onSecondarywarning)
            .border(Color.onSecondarywarning)
            .clipShape(RoundedRectangle(cornerRadius: .smallCornerRadius))
            .nbShadow()
    }
}

struct FABReplacementFullWidthButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.defaultPadding)
            .frame(maxWidth: .infinity)
            .background(Color.onSecondaryButtonSecondary)
            .foregroundStyle(Color.onPrimaryHighEmphasis)
            .clipShape(Capsule())
            .nbShadow()
    }
}
