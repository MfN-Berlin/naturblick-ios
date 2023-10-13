//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

extension Image {
    func avatar() -> some View {
        self
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: .avatarSize, height: .avatarSize)
    }
    
    func observationProperty() -> some View {
        self
            .resizable()
            .foregroundColor(.onSecondarySignalLow)
            .frame(width: .editTextIconSize, height: .editTextIconSize)
            .padding(.leading, .avatarOffsetPadding)
            .padding(.trailing, .avatarOffsetPadding + .defaultPadding)
    }
    func observationEditProperty() -> some View {
        self
            .resizable()
            .foregroundColor(.onSecondaryLowEmphasis)
            .frame(width: .editTextIconSize, height: .editTextIconSize)
            .padding(.leading, .avatarOffsetPadding)
            .padding(.trailing, .avatarOffsetPadding + .defaultPadding)
    }
}
