//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct HomeViewButton: View {

    let text: String
    let color: Color
    let image: Image
    let size: CGFloat

    var body: some View {
        VStack {
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
            Text(text)
                .foregroundColor(.onPrimaryHighEmphasis)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.nbCaption)
                .frame(width: size)
        }
        .font(.subheadline)
    }
}

struct HomeViewButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewButton(text: "Vogelstimmen aufnehmen",
                       color: Color.onPrimaryButtonPrimary,
                       image: Image(systemName: "questionmark"),
                       size: 75.0
        )
    }
}
