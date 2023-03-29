//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct HomeViewButton: View {

    let text: String
    let color: Color
    let width: CGFloat
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
                        .padding()
                }
                .frame(width: width)
            Text(text)
                .foregroundColor(.nbWhite)
                .alignmentGuide(.imageTitleAlignmentGuide) { context in
                        context[.firstTextBaseline]
                    }
                .multilineTextAlignment(TextAlignment.center)
        }
        .font(.subheadline)
    }
}

struct HomeViewButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewButton(text: "Vogelstimmen aufnehmen",
                       color: Color.secondary200,
                       width: 100,
                       image: Image(systemName: "questionmark")
        )
    }
}
