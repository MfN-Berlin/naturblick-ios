//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SpeciesListView: NavigatableView {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        switch(filter) {
        case .group(let group):
            return group.gerName
        case _:
            return "Species"
        }
    }
    
    @State var species:  [SpeciesListItem] = []
    @State var query: String = ""
    @StateObject var speciesListViewModel: SpeciesListViewModel = SpeciesListViewModel()
    let filter: SpeciesListFilter
    
    func updateFilter() {
        Task {
            do {
                species = try speciesListViewModel.query(filter: filter, search: query)
            } catch {
                preconditionFailure("\(error)")
            }
        }
    }
    
    func showSpecies(species: SpeciesListItem) {
        navigationController?.pushViewController(PortraitViewController(species: species, inSelectionFlow: false), animated: true)
    }
    
    var body: some View {
        List(species) { current in
            SpeciesListItemView(species: current)
                .onTapGesture {
                    showSpecies(species: current)
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
        }
        .listStyle(.plain)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: query) { query in
            updateFilter()
        }
        .onAppear {
            if species.isEmpty {
                updateFilter()
            }
        }
    }
}

struct SpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListView(filter: .group(Group.groups[0]))
    }
}
