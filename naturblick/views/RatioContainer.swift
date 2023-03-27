//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct RatioContainer<Content: View>: View {
    let heightRatio: CGFloat
    let content: Content

    init(heightRatio: CGFloat = 0.5, @ViewBuilder content: () -> Content) {
        self.heightRatio = heightRatio
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                content.frame(width: geo.size.width, height: geo.size.height * heightRatio)
            }
        }
    }
}
