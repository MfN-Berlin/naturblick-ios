//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SpeciesListView: View {
    @StateObject var speciesListViewModel: SpeciesListViewModel
    var createData: Binding<CreateData>?
    
    init(filter: SpeciesListFilter, createData: Binding<CreateData>? = nil) {
        _speciesListViewModel = StateObject(wrappedValue:  SpeciesListViewModel(filter: filter))
        self.createData = createData
    }

    var body: some View {
        BaseView {
            List(speciesListViewModel.species) { species in
                if let url = species.url {
                    // When used, AsyncImage has to be the outermost element
                    // or it will not properly load in List
                    AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                        SpeciesListItemView(species: species, avatar: image, createData: createData)
                    } placeholder: {
                        SpeciesListItemView(species: species, avatar: Image("placeholder"), createData: createData)
                    }
                    .listRowInsets(.nbInsets)
                    .listRowBackground(Color.secondaryColor)
                } else {
                    SpeciesListItemView(species: species, avatar: Image("placeholder"), createData: createData)
                        .listRowInsets(.nbInsets)
                        .listRowBackground(Color.secondaryColor)
                }
            }
            .listStyle(.plain)
            .searchable(text: $speciesListViewModel.query)
        }
    }
}

struct SpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListView(filter: .group(Group.groups[0]), createData: nil)
    }
}
