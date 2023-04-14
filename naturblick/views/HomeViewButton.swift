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
                        .foregroundColor(.nbWhite)
                        .padding(16)
                }
            Text(text)
                .foregroundColor(.nbWhite)
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
                       color: Color.secondary200,
                       image: Image(systemName: "questionmark")
        )
    }
}
