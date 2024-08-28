//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PickSpeciesListView<Flow>: NavigatableView where Flow: IdFlow {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Species"
    
    @State var page: Int = 0
    @State var species:  [SpeciesListItem] = []
    @State var query: String = ""
    @StateObject var pickSpeciesListViewModel: PickSpeciesListViewModel = PickSpeciesListViewModel()
   
    var flow: Flow
    
    func updateSpecies() {
        Task {
            do {
                species = try pickSpeciesListViewModel.query(search: query, page: page)
            } catch {
                Fail.with(error)
            }
        }
    }
    
    func showSpecies(species: SpeciesListItem) {
        viewController?.present(PopAwareNavigationController(rootViewController: SpeciesInfoView(selectionFlow: true, species: species, flow: flow).setUpViewController()), animated: true)
    }
    
    var body: some View {
        List(species) { current in
            SpeciesListItemView(species: current)
                .onTapGesture {
                    showSpecies(species: current)
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
                .onAppear {
                    allSpeciesPagination(item: current)
                }
        }
        .listStyle(.plain)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: query) { query in
            page = 0
            updateSpecies()
        }
        .onAppear {
            if species.isEmpty {
                updateSpecies()
            }
        }
    }
    
    func allSpeciesPagination(item: SpeciesListItem) {
        if let lastId = species.last?.id, lastId == item.id {
            page = page + 1
            Task {
                do {
                    species.append(contentsOf: try pickSpeciesListViewModel.query(search: query, page: page))
                } catch {
                    Fail.with(error)
                }
            }
        }
    }
}

struct AllSpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        PickSpeciesListView(flow: CreateFlowViewModel(backend: Backend(persistence:  ObservationPersistenceController(inMemory: true))))
    }
}
