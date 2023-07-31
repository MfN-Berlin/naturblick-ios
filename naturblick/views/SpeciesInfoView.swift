//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpeciesInfo: Identifiable {
    var id: String {
        species.id
    }
    let species: SpeciesListItem
    let avatar: Image
}

struct SpeciesInfoView: View {
    let info: SpeciesInfo
    var body: some View {
        VStack {
            info.avatar
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .padding(.trailing, .defaultPadding)
            
            if let name = info.species.name {
                Text(info.species.sciname)
                Text(name)
            } else {
                Text(info.species.sciname)
            }
            NavigationLink(destination: PortraitView(speciesId: info.species.speciesId)) {
                Text("Visit artportrait")
            }
        }.padding(.defaultPadding)
    }
}

struct SpeciesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesInfoView(info: SpeciesInfo(species: .sampleData, avatar: Image("placeholder")))
    }
}
