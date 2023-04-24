//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SpeciesListItemView: View {
    let species: SpeciesListItem
    let avatar: Image
    var body: some View {
        NavigationLink(destination: PortraitView(speciesId: species.speciesId)) {
            HStack(alignment: .top) {
                avatar
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: .avatarSize, height: .avatarSize)
                    .padding(.trailing, .defaultPadding)
                VStack(alignment: .leading) {
                    if let gername = species.name, let gersynonym = species.gersynonym {
                        Text(gername)
                            .subtitle1()
                        Text(species.sciname)
                            .subtitle3()
                        Text(gersynonym)
                            .subtitle3()
                            .padding(.bottom, .defaultPadding)
                    } else if let name = species.name {
                        Text(name)
                            .subtitle1()
                        Text(species.sciname)
                            .subtitle3()
                            .padding(.bottom, .defaultPadding)
                    } else if let gersynonym = species.gersynonym {
                        Text(species.sciname)
                            .subtitle1()
                        Text(gersynonym)
                            .subtitle3()
                            .padding(.bottom, .defaultPadding)
                    } else {
                        Text(species.sciname)
                            .subtitle1()
                    }
                }
                .padding(.top, .avatarTextOffset)
            }
        }
    }
}

struct SpeciesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListItemView(species: SpeciesListItem.sampleData, avatar: Image("placeholder"))
    }
}
