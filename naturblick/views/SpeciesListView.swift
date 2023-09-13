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
        case .characters(_, _):
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
        navigationController?.pushViewController(PortraitView(species: species).setUpViewController(), animated: true)
    }
    
    var body: some View {
        List(species) { current in
            if let url = current.url {
                // When used, AsyncImage has to be the outermost element
                // or it will not properly load in List
                AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                    SpeciesListItemView(species: current, avatar: image)
                        .onTapGesture {
                            showSpecies(species: current)
                        }
                } placeholder: {
                    SpeciesListItemView(species: current, avatar: Image("placeholder"))
                        .onTapGesture {
                            showSpecies(species: current)
                        }
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
            } else {
                SpeciesListItemView(species: current, avatar: Image("placeholder"))
                    .listRowInsets(.nbInsets)
                    .listRowBackground(Color.secondaryColor)
                    .onTapGesture {
                        showSpecies(species: current)
                    }
            }
        }
        .listStyle(.plain)
        .searchable(text: $query)
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
