//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)
import SwiftUI
import MapKit
import Photos
import Combine

class ObservationListViewModel: GroupSelector {
    @Published var showList: Bool
    @Published var selectedItems: Set<Observation> = Set<Observation>()
    @Published var editMode: EditMode = EditMode.inactive
    @Published var searchText: String? = nil
    @Published var group: GroupSelection = .all
    @Published var groups: [NamedGroup]
    @Published var observations: [Observation] = []

    init(persistenceController: ObservationPersistenceController, showList: Bool) {
        self.showList = showList
        self.groups = NamedGroup.fieldBookFilter()
        Publishers.CombineLatest4(persistenceController.$observations, $group, $groups, $searchText).map { (observations, group, groups, searchText) in
            let initial = persistenceController.observations
            let filteredByGroup = switch(group) {
            case .all: initial
            case .unknown:
                initial.filter { observation in
                    observation.species == nil
                }
            case .other:
                initial.filter { observation in
                    guard let species = observation.species else {
                        return false
                    }
                    return !groups.contains { group in
                        group.id == species.group.id
                    }
                }
            case let .group(group):
                initial.filter { observation in
                    observation.species?.group.id == group.id
                }
            }

            if let searchText = searchText, !searchText.isEmpty {
                return filteredByGroup.filter { observation in
                    return observation.species?.matches(searchText: searchText) ?? false
                }
            } else {
                return filteredByGroup
            }
        }
        .assign(to: &$observations)
    }
}

class ObservationListViewController: HostingController<ObservationListView>, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        model.searchText = searchController.searchBar.text?.lowercased()
    }
    
    let backend: Backend
    let createFlow: CreateFlowViewModel
    var deleteButton: UIBarButtonItem? = nil

    var model: ObservationListViewModel
    
    init(backend: Backend, showObservation: Observation? = nil) {
        self.backend = backend
        createFlow = CreateFlowViewModel(backend: backend, fromList: true)
        let m = ObservationListViewModel(persistenceController: backend.persistence, showList: showObservation == nil)
        model = m
        let view = ObservationListView(backend: backend, createFlow: createFlow, showObservation: showObservation, model: m)
        super.init(rootView: view)
        createFlow.setViewController(controller: self)
    }
    
    @objc func openMenu(sender: AnyObject) {
        let menuVC = MenuController(entries: [
               MenuEntry(title: String(localized: "record_a_bird"), image: UIImage(named: "audio24")!) {
                   self.createFlow.recordSound()
               },
               MenuEntry(title: String(localized: "photograph_a_plant"), image: UIImage(named: "photo24")!) {
                   self.createFlow.takePhoto()
               },
               MenuEntry(title: String(localized: "create_obs"), image: UIImage(named: "logo24")!) {
                   self.createFlow.createWithSearch()
               },
               MenuEntry(title: String(localized: "import_image"), image: UIImage(named: "ic_phone_action_image")!) {
                   self.createFlow.createFromPhoto()
               }
           ], width: 300);
           
           menuVC.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
           navigationController?.present(menuVC, animated: true)
    }
    
    func setStandardMode() {
        DispatchQueue.main.async {
            let selectButton = UIBarButtonItem(title: String(localized: "select"), style: .plain, target: self, action: #selector(ObservationListViewController.changeEditMode))
            let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(ObservationListViewController.openMenu))
            let mapButton = UIBarButtonItem(primaryAction: UIAction(image: UIImage(systemName: self.model.showList ? "map" : "map.fill")) { action in
                self.model.showList.toggle()
                self.configureNavigationItem()
            })
            addButton.accessibilityLabel = String(localized: "acc_add")
            mapButton.accessibilityLabel = String(localized: self.model.showList ? "acc_map" : "acc_format_list_bulleted")
            let listButtons = [ mapButton, addButton, selectButton ]
            let mapButtons = [ mapButton, addButton ]
            self.navigationItem.setRightBarButtonItems( self.model.showList ? listButtons : mapButtons, animated: true)
        }
    }
    
    func setEditMode() {
        DispatchQueue.main.async {
            let stopSelectButton = UIBarButtonItem(title: String(localized: "cancel"), style: .plain, target: self, action: #selector(ObservationListViewController.changeEditMode))
            self.deleteButton = UIBarButtonItem(image: UIImage(named: "trash_24"), style: .plain, target: self, action: #selector(ObservationListViewController.deleteObservations))
            self.deleteButton?.accessibilityLabel = String(localized: "acc_delete")
            self.deleteButton?.tintColor = UIColor(Color.onPrimaryHighEmphasis)
            self.deleteButton?.isEnabled = self.model.selectedItems.count > 0
            if let db = self.deleteButton {
                let buttons = [ db, stopSelectButton ]
                self.navigationItem.setRightBarButtonItems(buttons, animated: true)
            }
        }
    }
    
    func enableDelete(enabled: Bool) {
        deleteButton?.isEnabled = enabled
    }
    
    func configureNavigationItem() {
        if (model.editMode == .inactive) {
            setStandardMode()
        } else {
            setEditMode()
        }
    }
    
    @objc func changeEditMode(_ sender: Any?) {
        model.editMode = model.editMode == .active ? .inactive : .active
        model.selectedItems.removeAll()
    }
    
    @objc func deleteObservations(_ sender: Any?) {
        var title: String
        var msg: String
        
        if (model.selectedItems.count == 1) {
            title = String(localized: "delete_question")
            msg = String(localized: "delete_question_message")
        } else {
            let countStr = "\(model.selectedItems.count)"
            title = String(localized: "delete_question_plural")
            msg = String(localized: "delete_question_message_plural \(countStr)")
        }
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: String(localized: "delete"), style: .destructive, handler: { _ in
            do {
                let selectedOccurenceIds = self.model.selectedItems.map { o in
                    o.observation.occurenceId
                }
                try self.backend.persistence.delete(occurenceIds: selectedOccurenceIds)
                self.model.selectedItems.removeAll()
                self.model.editMode = .inactive
            } catch {
                fatalError(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: String(localized: "cancel"), style: .cancel, handler: { _ in
        }))
        alert.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = setupSearchController()
        searchController.searchResultsUpdater = self
    }
}

struct ObservationListView: HostedView {    
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? = String(localized: "field_book")
    
    let backend: Backend
    @StateObject private var locationManager = LocationManager()
    @StateObject private var errorHandler = HttpErrorViewModel()
    @State private var userTrackingMode: MKUserTrackingMode = .none
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var createFlow: CreateFlowViewModel
    @ObservedObject var model: ObservationListViewModel
    @State var showDelete: Bool = false
    @State var deleteObservation: IndexSet? = nil
    
    let showObservation: Observation?
    
    init(backend: Backend, createFlow: CreateFlowViewModel, showObservation: Observation?, model: ObservationListViewModel) {
        self.backend = backend
        self.persistenceController = backend.persistence
        self.createFlow = createFlow
        self.showObservation = showObservation
        self.model = model
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        if let controller = viewController as? ObservationListViewController {
            controller.configureNavigationItem()
        }
    }
    
    private func reinitNav() {
        if let item = viewController?.navigationItem {
            configureNavigationItem(item: item)
        }
    }
    
    @ViewBuilder
    private func createListItem(observation: Observation) -> some View {
        let obsListItem = ObservationListItemWithImageView(observation: observation, backend: backend, editMode: model.editMode)
            .listRowInsets(.nbInsets)
            .listRowBackground(Color.secondaryColor)
            .accessibilityElement(children: .combine)
        
        if (model.editMode == .inactive) {
            obsListItem
                .onTapGesture {
                    navigationController?.pushViewController(ObservationViewController(occurenceId: observation.id, backend: backend), animated: true)
                }
        } else {
            obsListItem
        }
    }
    
    var body: some View {
        VStack {
            if(model.showList) {
                List(model.observations, id: \.self, selection: $model.selectedItems) { observation in
                    createListItem(observation: observation)
                }
                .environment(\.editMode, .constant(model.editMode))
                .foregroundColor(.onPrimaryHighEmphasis)
                .animation(.default, value: persistenceController.observations)
                .listStyle(.plain)
                .refreshable {
                    do {
                        try await backend.sync()
                    } catch {
                        errorHandler.handle(error)
                    }
                }
                .onChange(of: model.editMode) { _ in
                    reinitNav()
                }
                .onChange(of: model.selectedItems.count) { count in
                    (viewController as? ObservationListViewController)?.enableDelete(enabled: count > 0)
                }
            } else {
                ObservationMapView(
                    backend: backend,
                    userTrackingMode: $userTrackingMode,
                    initial: showObservation,
                    model: model) { observation in
                        navigationController?.pushViewController(ObservationViewController(occurenceId: observation.id, backend: backend), animated: true)
                    }
                .trackingToggle($userTrackingMode: $userTrackingMode, authorizationStatus: locationManager.permissionStatus)
                .onAppear {
                    if(locationManager.askForPermission()) {
                        locationManager.requestLocation()
                    }
                }
            }
            HStack(alignment: .center, spacing: .defaultPadding) {
                VStack {
                    Text(model.group.description)
                        .button()
                        .foregroundColor(.onSecondarySignalLow)
                        .multilineTextAlignment(.center)
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    viewController?.present(PopAwareNavigationController(rootViewController: SelectGroupView(selector: model, provider: persistenceController).setUpViewController()), animated: true)
                }
                Text("\(model.observations.count) obs_count", tableName: "Plurals")
                    .body2()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer().frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, .defaultPadding)
        }
        .task {
            try? await backend.sync()
        }
        .onReceive(model.$showList) { showList in
            if let item = viewController?.navigationItem {
                configureNavigationItem(item: item)
            }
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error) { error in
            if case .loggedOut = error {
                Button("sign_out") {
                    Keychain.shared.deleteEmail()
                }
                Button("to_sign_in") {
                    navigationController?.pushViewController(LoginView(accountViewModel: AccountViewModel(backend: backend)).setUpViewController(), animated: true)
                }
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .navigationBarBackButtonHidden(model.editMode == .active)
    }
    
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        let backend = Backend(persistence: ObservationPersistenceController(inMemory: true))
        ObservationListView(backend: backend, createFlow: CreateFlowViewModel(backend: backend), showObservation: nil, model: ObservationListViewModel(persistenceController: backend.persistence, showList: true))
    }
}
