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

class PickSpeciesListViewController<Flow>: HostingController<PickSpeciesListView<Flow>>, UISearchResultsUpdating, UISearchControllerDelegate where Flow: IdFlow {
    
    let pickSpeciesListModel = PickSpeciesListModel()
    
    init(flow: Flow) {
        let view = PickSpeciesListView(flow: flow, pickSpeciesListModel: pickSpeciesListModel)
        super.init(rootView: view)
        setupSearchController()
        updateSearchResults(for: searchController)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        pickSpeciesListModel.query = searchController.searchBar.text?.lowercased() ?? ""
        pickSpeciesListModel.updateSpecies()
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        let glassIconView = searchController.searchBar.searchTextField.leftView as? UIImageView
        glassIconView?.tintColor = UIColor.onPrimaryMininumEmphasis
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = false
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarCustomStyling()
    }
    
    // it's important to set the textColor in viewDidLoad, otherwise the custom setting is overwriten somewhere else magically
    private func searchBarCustomStyling() {
        let sb = searchController.searchBar
        let stf = sb.searchTextField
        let glasIconView = searchController.searchBar.searchTextField.leftView as? UIImageView
        
        glasIconView?.tintColor = .onPrimaryMininumEmphasis
        stf.attributedPlaceholder = NSAttributedString(
            string: String(localized: "search"),
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.onPrimaryMininumEmphasis]
        )
        
        stf.textColor = .onPrimaryHighEmphasis
        stf.backgroundColor = UIColor.onPrimaryButtonSecondary
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
     searchController.searchBar.searchTextField.backgroundColor = UIColor.onPrimaryInput
    }

    func willDismissSearchController(_ searchController: UISearchController) {
     searchController.searchBar.searchTextField.backgroundColor = UIColor.onPrimaryButtonSecondary
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
