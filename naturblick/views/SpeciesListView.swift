//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct SpeciesListView: View {
    @StateObject var speciesListViewModel = SpeciesListViewModel()
    let filter: SpeciesListFilter

    var body: some View {
        List(speciesListViewModel.species) { species in
            if let url = species.maleUrl {
                // When used, AsyncImage has to be the outermost element
                // or it will not properly load in List
                AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                    SpeciesListItemView(species: species, avatar: image)
                } placeholder: {
                    SpeciesListItemView(species: species, avatar: Image("placeholder"))
                }
            } else {
                SpeciesListItemView(species: species, avatar: Image("placeholder"))
            }
        }
        .task {
            speciesListViewModel.filter(filter: filter)
        }
    }
}

struct SpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListView(filter: .group(Group.groups[0]))
    }
}
