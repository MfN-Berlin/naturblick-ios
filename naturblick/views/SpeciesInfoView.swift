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
            if info.species.hasPortrait {
                NavigationLink(destination: PortraitView(speciesId: info.species.speciesId)) {
                    Text("Visit artportrait")
                }
            } else if let wikipedia = info.species.wikipedia {
                Link("Visit wikipedia", destination: URL(string: wikipedia)!)
            }
        }.padding(.defaultPadding)
    }
}

struct SpeciesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesInfoView(info: SpeciesInfo(species: .sampleData, avatar: Image("placeholder")))
    }
}
