//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SpeciesListView: NavigatableView {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        switch(filter) {
        case .group(let group):
            return isGerman() ? group.gerName : group.engName
        case _:
            return String(localized: "species")
        }
    }
    
    @State var species:  [SpeciesListItem] = []
    @State var query: String = ""
    @StateObject var speciesListViewModel: SpeciesListViewModel = SpeciesListViewModel()
    let filter: SpeciesListFilter
    @ObservedObject var flow: CreateFlowViewModel
    var isCharacterResult: Bool = false
    
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
        if isCharacterResult {
            viewController?.present(InSheetPopAwareNavigationController(rootViewController: SpeciesInfoView(species: species, flow: flow).setUpViewController()), animated: true)
        } else {
            viewController?.navigationController?.pushViewController(PortraitViewController(species: species, inSelectionFlow: false, createFlow: flow), animated: true)
        }
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
        SpeciesListView(filter: .group(Group.groups[0]), flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
