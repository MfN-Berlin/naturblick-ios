//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct RoundBottomShape: Shape {
    func path(in rect: CGRect) -> Path {
        let offset = .roundBottomHeight * .leftRightQuadHeightFactor
        return Path { path in
            path.move(
                to: CGPoint(
                    x: 0.0,
                    y: rect.height - .roundBottomHeight - offset
                )
            )
            
            path.addQuadCurve(
                to: CGPoint(
                    x: offset,
                    y: rect.height - .roundBottomHeight
                ),
                control: CGPoint(
                    x: 0.0,
                    y: rect.height - .roundBottomHeight
                )
            )
            path.addQuadCurve(
                to: CGPoint(
                    x: rect.width - offset,
                    y: rect.height - .roundBottomHeight
                ),
                control: CGPoint(
                    x: rect.width * 0.5,
                    y: rect.height
                )
            )
            path.addQuadCurve(
                to: CGPoint(
                    x: rect.width,
                    y: rect.height - .roundBottomHeight - offset
                ),
                control: CGPoint(
                    x: rect.width,
                    y: rect.height - .roundBottomHeight
                )
            )
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: 0.0
                )
            )
            path.addLine(
                to: CGPoint(
                    x: 0.0,
                    y: 0.0
                )
            )
            path.addLine(
                to: CGPoint(
                    x: 0.0,
                    y: rect.height - .roundBottomHeight
                )
            )
        }
    }
}
