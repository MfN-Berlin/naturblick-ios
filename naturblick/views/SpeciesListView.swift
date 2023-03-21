//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct SpeciesListView: View {
    @StateObject var speciesListViewModel = SpeciesListViewModel()
    let filter: SpeciesListFilter

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(speciesListViewModel.species, id: \.id) { species in
                    Text(species.sciname)
                }
            }
        }.task {
            speciesListViewModel.filter(filter: filter)
        }
    }
}

struct SpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListView(filter: .group(Group.groups[0]))
    }
}
