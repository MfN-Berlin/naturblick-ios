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
}
