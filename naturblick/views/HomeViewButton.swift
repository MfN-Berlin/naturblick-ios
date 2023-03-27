//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct HomeViewButton: View {

    let text: String
    let color: Color
    let width: CGFloat
    let image: () -> Image

    var body: some View {
        VStack {
            ZStack {
                Circle().fill(color)
                image()
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.5, height: width * 0.5)
                    .foregroundColor(.nbWhite)
                    
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
        HomeViewButton(text: "Vogelstimmen aufnehmen", color: Color.secondary200, width: 100) {
            Image(systemName: "questionmark")
        }
    }
}
