//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct PickSpeciesListView: View {
    @Binding var picked: SpeciesListItem?
    @State var species:  [SpeciesListItem] = []
    @State var page: Int = 0
    @State var query: String = ""
    @StateObject var speciesListViewModel = SpeciesListViewModel()
    @State var showInfo: SpeciesListItem? = nil
    
    func reloadSpecies() {
        Task {
            do {
                species = try speciesListViewModel.query(search: query, page: page)
            } catch {
                preconditionFailure("\(error)")
            }
        }
    }
    
    func itemAppear(item: SpeciesListItem) {
        if let lastId = species.last?.id, lastId == item.id {
            page = page + 1
            Task {
                do {
                    species.append(contentsOf: try speciesListViewModel.query(search: query, page: page))
                } catch {
                    preconditionFailure("\(error)")
                }
            }
        }
    }
    
    var body: some View {
        List(species) { current in
            SpeciesListItemView(species: current)
                .onTapGesture {
                    showInfo = current
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
                .onAppear {
                    itemAppear(item: current)
                }
        }
        .listStyle(.plain)
        .searchable(text: $query)
        .onChange(of: query) { query in
            page = 0
            reloadSpecies()
        }
        .onAppear {
            if species.isEmpty {
                reloadSpecies()
            }
        }
        .popover(item: $showInfo) { species in
            NavigationView {
                Text("Test")
                    .navigationTitle(species.name != nil ? species.name! : species.sciname)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Select") {
                                picked = species
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                showInfo = nil
                            }
                        }
                    }
            }
        }
    }
}

struct PaginatedSpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        PickSpeciesListView(picked: .constant(nil))
    }
}
