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
                            .font(.nbSubtitle1)
                            .foregroundColor(.onSecondaryHighEmphasis)
                        Text(species.sciname)
                            .font(.nbSubtitle3)
                            .foregroundColor(.onSecondarySignalLow)
                        Text(gersynonym)
                            .font(.nbSubtitle3)
                            .padding(.bottom, .defaultPadding)
                            .foregroundColor(.onSecondarySignalLow)
                    } else if let name = species.name {
                        Text(name)
                            .font(.nbSubtitle1)
                            .foregroundColor(.onSecondaryHighEmphasis)
                        Text(species.sciname)
                            .font(.nbSubtitle3)
                            .foregroundColor(Color.onSecondarySignalLow)
                            .padding(.bottom, .defaultPadding)
                    } else if let gersynonym = species.gersynonym {
                        Text(species.sciname)
                            .font(.nbSubtitle1)
                            .foregroundColor(.onSecondaryHighEmphasis)
                        Text(gersynonym)
                            .font(.nbSubtitle3)
                            .padding(.bottom, .defaultPadding)
                            .foregroundColor(Color.onSecondarySignalLow)
                    } else {
                        Text(species.sciname)
                            .font(.nbSubtitle1)
                            .foregroundColor(.onSecondaryHighEmphasis)
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
