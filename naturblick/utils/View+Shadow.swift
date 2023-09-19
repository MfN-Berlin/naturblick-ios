//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

extension View {
    func nbShadow() -> some View {
        self
            .shadow(color: .shadowBlackOpacity10, radius: 16, x: 0, y: 10)
            .shadow(color: .shadowGreyOpacity5, radius: 6, x: 0, y: 4)
            .shadow(color: .shadowBlackOpacity5, radius: 8, x: 0, y: -2)
    }
}
