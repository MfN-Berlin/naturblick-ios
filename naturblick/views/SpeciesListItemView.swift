//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct SpeciesListItemView: View {
    let species: Species
    let avatar: Image
    var body: some View {
        HStack(alignment: .top) {
            avatar
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 64, height: 64)
            VStack(alignment: .leading) {
                if let gername = species.gername {
                    Text(gername)
                        .bold()
                    Text(species.sciname)
                        .foregroundColor(Color.blue)
                } else {
                    Text(species.sciname)
                        .bold()
                }
                if let gersynonym = species.gersynonym {
                    Text(gersynonym)
                        .italic()
                }
            }
            .padding(.top, 8)
        }
    }
}

struct SpeciesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListItemView(species: Species.sampleData, avatar: Image("placeholder"))
    }
}
