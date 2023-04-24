//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct RoundBottomView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width: CGFloat = geometry.size.width
                let height = width * 0.1
                path.move(
                    to: CGPoint(
                        x: width,
                        y: 0.0
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: width,
                        y: height
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: 0.0,
                        y: height
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: 0.0,
                        y: 0.0
                    )
                )
                path.addQuadCurve(
                    to: CGPoint(
                        x: width,
                        y: 0.0
                    ),
                    control: CGPoint(
                        x: width * 0.5,
                        y: height
                    )
                )
            }
            .fill(Color.primaryColor)
        }
    }
}

struct RoundBottomView_Previews: PreviewProvider {
    static var previews: some View {
        RoundBottomView()
    }
}
