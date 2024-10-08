//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class PickSpeciesListModel: ObservableObject {
    var page: Int = 0
    var query: String = "" {
        didSet {
            page = 0
        }
    }
    @Published var species:  [SpeciesListItem] = []
    let pickSpeciesListProvider = PickSpeciesListProvider()

    func allSpeciesPagination(item: SpeciesListItem) {
        if let lastId = species.last?.id, lastId == item.id {
            page = page + 1
            appendSpecies()
        }
    }
    
    func updateSpecies() {
        do {
            species = try pickSpeciesListProvider.query(search: query, page: page)
        } catch {
            Fail.with(error)
        }
    }
    
    func appendSpecies() {
        do {
            species.append(contentsOf: try pickSpeciesListProvider.query(search: query, page: page))
        } catch {
            Fail.with(error)
        }
    }
}

class PickSpeciesListViewController<Flow>: HostingController<PickSpeciesListView<Flow>>, UISearchResultsUpdating where Flow: IdFlow {
    
    let pickSpeciesListModel = PickSpeciesListModel()
    
    init(flow: Flow) {
        let view = PickSpeciesListView(flow: flow, pickSpeciesListModel: pickSpeciesListModel)
        super.init(rootView: view)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        pickSpeciesListModel.query = searchController.searchBar.text?.lowercased() ?? ""
        pickSpeciesListModel.updateSpecies()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = setupSearchController()
        searchController.searchResultsUpdater = self
        updateSearchResults(for: searchController)
    }
}

struct PickSpeciesListView<Flow>: HostedView where Flow: IdFlow {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Species"
    var flow: Flow
    @ObservedObject var pickSpeciesListModel: PickSpeciesListModel
    
    func showSpecies(species: SpeciesListItem) {
        viewController?.present(PopAwareNavigationController(rootViewController: SpeciesInfoView(selectionFlow: true, species: species, flow: flow).setUpViewController()), animated: true)
    }
    
    var body: some View {
        List(pickSpeciesListModel.species) { current in
            SpeciesListItemView(species: current)
                .onTapGesture {
                    showSpecies(species: current)
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
                .onAppear {
                    pickSpeciesListModel.allSpeciesPagination(item: current)
                }
        }
        .listStyle(.plain)
        .foregroundColor(.onPrimaryHighEmphasis)
    }
}


 struct AllSpeciesListView_Previews: PreviewProvider {
     static var previews: some View {
         PickSpeciesListView(flow: CreateFlowViewModel(backend: Backend(persistence:  ObservationPersistenceController(inMemory: true))), pickSpeciesListModel: PickSpeciesListModel())
     }
 }
