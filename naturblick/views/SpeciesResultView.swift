//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpeciesResultView: View {
    let result: SpeciesResult
    let species: SpeciesListItem
    let avatar: Image
    
    var color: Color {
        if result.score > 50 {
            return .onSecondarySignalMedium
        } else {
            return .onSecondarySignalLow
        }
    }
    var body: some View {
        HStack {
            avatar
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: .avatarSize, height: .avatarSize)
                .padding(.trailing, .defaultPadding)
            VStack(alignment: .leading) {
                if let gername = species.name {
                    Text(gername)
                        .subtitle1()
                } else {
                    Text(species.sciname)
                        .subtitle1()
                }
                Text(String(format: "Score: %.0f%%", result.score.rounded()))
                    .subtitle3(color: color)
            }
        }
    }
}

struct SpeciesResultView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesResultView(result: .init(id: 1, score: 42), species: .sampleData, avatar: Image("placeholder"))
    }
}
