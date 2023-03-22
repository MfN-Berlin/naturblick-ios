//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct HomeViewButton: View {

    let text: String
    let image: () -> Image

    var body: some View {
        VStack {
            ZStack {
                Circle().fill(Color.secondary200)
                image()
                    .foregroundColor(.nbWhite)
                    .padding()
            }
            Text(text)
                .multilineTextAlignment(TextAlignment.center)
                .foregroundColor(.nbWhite)
            }
    }
}

struct HomeViewButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewButton(text: "Vogelstimmen aufnehmen") {
            Image(systemName: "mic")
        }
    }
}
