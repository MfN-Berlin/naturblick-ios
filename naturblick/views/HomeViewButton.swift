//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct HomeViewButton: View {

    let text: String
    let image: Image

    var body: some View {
        VStack {
            Circle()
                .fill(.secondary)
                .overlay {
                    image
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.onSecondaryHighEmphasis)
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
                       image: Image(systemName: "questionmark")
        )
    }
}
