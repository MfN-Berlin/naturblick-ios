//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpeciesListView: NavigatableView {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Species"
    
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
    
    var body: some View {
        List(species) { current in
            if let url = current.url {
                // When used, AsyncImage has to be the outermost element
                // or it will not properly load in List
                AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                    NavigationLink(destination: PortraitView(speciesId: current.speciesId)) {
                        SpeciesListItemView(species: current, avatar: image)
                    }
                } placeholder: {
                    NavigationLink(destination: PortraitView(speciesId: current.speciesId)) {
                        SpeciesListItemView(species: current, avatar: Image("placeholder"))
                    }
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
            } else {
                NavigationLink(destination: PortraitView(speciesId: current.speciesId)) {
                    SpeciesListItemView(species: current, avatar: Image("placeholder"))
                        .listRowInsets(.nbInsets)
                        .listRowBackground(Color.secondaryColor)
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
