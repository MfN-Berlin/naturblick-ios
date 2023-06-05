//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

extension Map {
    func picker() -> some View {
        self
            .overlay(alignment: .center) {
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: 50)
            Rectangle()
                .fill(Color.white)
                .frame(width: 50, height: 2)
            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
        }
    }
}
