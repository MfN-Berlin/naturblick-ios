//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

class SpeciesListViewModel: ObservableObject {
    @Published var species: [SpeciesListItem] = []
}

class SpeciesListViewController: HostingController<SpeciesListView>, UISearchResultsUpdating {
    
    let countView: Bool
    let filter: SpeciesListFilter
    let flow: CreateFlowViewModel
    let isCharacterResult: Bool = false
    let speciesListModel = SpeciesListViewModel()
    private let speciesProvider = SpeciesListProvider()
    
    init(filter: SpeciesListFilter, flow: CreateFlowViewModel, backend: Backend, countView: Bool, isCharacterResult: Bool = false) {
        self.filter = filter
        self.flow = flow
        self.countView = countView
        let view = SpeciesListView(backend: backend, filter: filter, flow: flow, isCharacterResult: isCharacterResult, speciesListModel: speciesListModel, countView: countView)
        super.init(rootView: view)
    }
    
    private func updateSpecies(filter: SpeciesListFilter, searchText: String?) {
        do {
            speciesListModel.species = try speciesProvider.query(filter: filter, search: searchText ?? "")
        } catch {
            Fail.with(error)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        updateSpecies(filter: filter, searchText: searchController.searchBar.text?.lowercased())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = setupSearchController()
        searchController.searchResultsUpdater = self
        updateSearchResults(for: searchController)
    }
}

struct SpeciesListView: HostedView {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        switch(filter) {
        case .group(let group):
            return group.name
        case _:
            return String(localized: "species")
        }
    }
    
    let backend: Backend
    let filter: SpeciesListFilter
    @ObservedObject var flow: CreateFlowViewModel
    let isCharacterResult: Bool
    @ObservedObject var speciesListModel: SpeciesListViewModel
    let countView: Bool
    
    func showSpecies(species: SpeciesListItem) {
        if isCharacterResult {
            viewController?.present(PopAwareNavigationController(rootViewController: SpeciesInfoView(backend: backend, countView: countView, selectionFlow: true, species: species, flow: flow).setUpViewController()), animated: true)
        } else {
            viewController?.navigationController?.pushViewController(SpeciesInfoView(backend: backend, countView: countView, selectionFlow: false, species: species, flow: flow).setUpViewController(), animated: true)
        }
    }
    
    var body: some View {
        List(speciesListModel.species) { current in
            SpeciesListItemView(species: current)
                .onTapGesture {
                    showSpecies(species: current)
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
        }
        .listStyle(.plain)
        .foregroundColor(.onPrimaryHighEmphasis)
    }
}

struct SpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        let backend = Backend(persistence: ObservationPersistenceController(inMemory: true))
        SpeciesListView(backend: backend, filter: .group(NamedGroup.exampleData), flow: CreateFlowViewModel(backend: backend), isCharacterResult: false, speciesListModel: SpeciesListViewModel(), countView: false)
    }
}
