//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit
import Photos

class ObservationListViewModel: ObservableObject {
    @Published var showList: Bool
    
    init(showList: Bool) {
        self.showList = showList
    }
}

class ObservationListViewController: HostingController<ObservationListView> {
    let backend: Backend
    let createFlow: CreateFlowViewModel
    init(backend: Backend, showObservation: Observation? = nil) {
        self.backend = backend
        createFlow = CreateFlowViewModel(backend: backend, fromList: true)
        let view = ObservationListView(backend: backend, createFlow: createFlow, showObservation: showObservation)
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
    @StateObject var model: ObservationListViewModel
    @State var showDelete: Bool = false
    @State var deleteObservation: IndexSet? = nil
    let showObservation: Observation?
    @State var searchText: String = ""
    
    init(backend: Backend, createFlow: CreateFlowViewModel, showObservation: Observation?) {
        self.backend = backend
        self.persistenceController = backend.persistence
        self.createFlow = createFlow
        self.showObservation = showObservation
        self._model = StateObject(wrappedValue: ObservationListViewModel(showList: showObservation == nil)
        )
    }
    
    func configureNavigationItem(item: UINavigationItem, showList: Bool) {
        let addButton = UIBarButtonItem(image: UIImage(named: "add_24"), style: .plain, target: viewController, action: #selector(ObservationListViewController.openMenu))
        let mapButton = UIBarButtonItem(primaryAction: UIAction(image: UIImage(named: showList ? "map" : "format_list_bulleted")) {action in
            model.showList.toggle()
        })
        addButton.accessibilityLabel = String(localized: "acc_add")
        mapButton.accessibilityLabel = String(localized: showList ? "acc_map" : "acc_format_list_bulleted")
        item.rightBarButtonItems = [ addButton, mapButton]
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        configureNavigationItem(item: item, showList: true)
    }
    
    var body: some View {
        SwiftUI.Group {
            if(model.showList) {
                List {
                    ForEach(observations) {
                        observation in
                        ObservationListItemWithImageView(observation: observation, backend: backend)
                            .listRowInsets(.nbInsets)
                            .listRowBackground(Color.secondaryColor)
                            .onTapGesture {
                                navigationController?.pushViewController(ObservationViewController(occurenceId: observation.id, backend: backend), animated: true)
                            }
                            .accessibilityElement(children: .combine)
                    }
                }
                .searchable(text: $searchText)
                .animation(.default, value: persistenceController.observations)
                .listStyle(.plain)
                .refreshable {
                    do {
                        try await backend.sync()
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            } else {
                ObservationMapView(
                    backend: backend,
                    userTrackingMode: $userTrackingMode,
                    initial: showObservation) { observation in
                        navigationController?.pushViewController(ObservationViewController(occurenceId: observation.id, backend: backend), animated: true)
                    }
                .trackingToggle($userTrackingMode: $userTrackingMode, authorizationStatus: locationManager.permissionStatus)
                .onAppear {
                    if(locationManager.askForPermission()) {
                        locationManager.requestLocation()
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .task {
            try? await backend.sync()
        }
        .onReceive(model.$showList) { showList in
            if let item = viewController?.navigationItem {
                configureNavigationItem(item: item, showList: showList)
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
    }
    
    var observations: [Observation] {
        if (searchText.isEmpty) {
           return persistenceController.observations
       } else {
           return persistenceController.observations.filter {
               let str = searchText.lowercased()
               return $0.species?.gername?.lowercased().contains(str) ?? false
               || $0.species?.gersynonym?.lowercased().contains(str) ?? false
               || $0.species?.engname?.lowercased().contains(str) ?? false
               || $0.species?.engsynonym?.lowercased().contains(str) ?? false
               || $0.species?.sciname.lowercased().contains(str) ?? false }
       }
    }
      
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        let backend = Backend(persistence: ObservationPersistenceController(inMemory: true))
        ObservationListView(backend: backend, createFlow: CreateFlowViewModel(backend: backend), showObservation: nil)
    }
}
