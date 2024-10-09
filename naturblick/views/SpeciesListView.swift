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
    @StateObject var speciesListViewModel: SpeciesListViewModel = SpeciesListViewModel()
    let filter: SpeciesListFilter
    @ObservedObject var flow: CreateFlowViewModel
    var isCharacterResult: Bool = false
    
    @State var species:  [SpeciesListItem] = []
    @ObservedObject var searchModel: SearchModel
    
    func updateSpeciesList() {
        print("updateSpeciesList()")
        do {
            species = try speciesListViewModel.query(filter: filter, search: searchModel.query ?? "")
        } catch {
            Fail.with(error)
        }
    }
    
    
    func searchController() -> UISearchController? {
        UISearchController(searchResultsController: nil)
    }
    
    func updateSearchResult(searchText: String?) {
        print("updateSearchResult in SpeciesListView \(String(describing: searchText))")
        if let searchModel = holder.searchModel {
            searchModel.query = searchText
        }
    }
    
    func showSpecies(species: SpeciesListItem) {
        if isCharacterResult {
            viewController?.present(PopAwareNavigationController(rootViewController: SpeciesInfoView(selectionFlow: true, species: species, flow: flow).setUpViewController()), animated: true)
        } else {
            viewController?.navigationController?.pushViewController(SpeciesInfoView(selectionFlow: false, species: species, flow: flow).setUpViewController(), animated: true)
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
       // .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .foregroundColor(.onPrimaryHighEmphasis)
        .onChange(of: searchModel.query) { query in
            print("onChange")
            updateSpeciesList()
        }
        .onAppear {
            updateSpeciesList()
        }
    }
}

struct SpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListView(filter: .group(Group.groups[0]), flow: CreateFlowViewModel(backend: Backend(persistence: ObservationPersistenceController(inMemory: true))))
    }
}
