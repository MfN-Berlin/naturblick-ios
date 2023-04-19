//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct HomeViewButton: View {

    let text: String
    let color: Color
    let image: Image

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
            Text(text)
                .foregroundColor(.onPrimaryHighEmphasis)
                .multilineTextAlignment(TextAlignment.center)
                .font(.nbCaption)
            Spacer()
        }
        .font(.subheadline)
    }
}

struct HomeViewButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewButton(text: "Vogelstimmen aufnehmen",
                       color: Color.onPrimaryButtonPrimary,
                       image: Image(systemName: "questionmark")
        )
    }
}
