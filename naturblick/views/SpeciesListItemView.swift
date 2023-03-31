//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

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
                        Text(species.sciname)
                            .font(.nbSubtitle3)
                            .foregroundColor(Color.secondary200)
                        Text(gersynonym)
                            .font(.nbSubtitle3)
                            .padding(.bottom, .defaultPadding)
                    } else if let name = species.name {
                        Text(name)
                            .font(.nbSubtitle1)
                        Text(species.sciname)
                            .font(.nbSubtitle3)
                            .foregroundColor(Color.secondary200)
                            .padding(.bottom, .defaultPadding)
                    } else if let gersynonym = species.gersynonym {
                        Text(species.sciname)
                            .font(.nbSubtitle1)
                        Text(gersynonym)
                            .font(.nbSubtitle3)
                            .padding(.bottom, .defaultPadding)
                    } else {
                        Text(species.sciname)
                            .font(.nbSubtitle1)
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
