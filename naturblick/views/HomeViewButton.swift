//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct HomeViewButton: View {
    let text: String
    let color: Color
    let image: Image
    let size: CGFloat
    let action: () -> ()

    var body: some View {
        VStack(spacing: .defaultPadding) {
            Circle()
                .fill(color)
                .overlay {
                    image
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.onPrimaryHighEmphasis)
                        .padding(16)
                }
                .frame(width: size, height: size)
                .nbShadow()
                Text(text)
                    .bigRoundButtonText(size: size)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    .frame(width: size)
        }.accessibilityRepresentation {
            Button(text) {
                action()
            }
        }
        .onTapGesture {
            action()
        }
    }
}

struct HomeViewButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewButton(text: "Vogelstimmen aufnehmen",
                       color: Color.onPrimaryButtonPrimary,
                       image: Image(systemName: "questionmark"),
                       size: 75.0
        ) {}
    }
}
