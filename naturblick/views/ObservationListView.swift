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
    let persistenceController: ObservationPersistenceController
    let createFlow: CreateFlowViewModel
    init(persistenceController: ObservationPersistenceController, showObservation: Observation? = nil) {
        self.persistenceController = persistenceController
        createFlow = CreateFlowViewModel(persistenceController: persistenceController, fromList: true)
        let view = ObservationListView(persistenceController: persistenceController, createFlow: createFlow, showObservation: showObservation)
        super.init(rootView: view)
        createFlow.setViewController(controller: self)
    }
}

struct ObservationListView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? = String(localized: "field_book")
    
    private let client = BackendClient()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var errorHandler = HttpErrorViewModel()
    @State private var userTrackingMode: MKUserTrackingMode = .none
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var createFlow: CreateFlowViewModel
    @StateObject var model: ObservationListViewModel
    let showObservation: Observation?
    
    init(persistenceController: ObservationPersistenceController, createFlow: CreateFlowViewModel, showObservation: Observation?) {
        self.persistenceController = persistenceController
        self.createFlow = createFlow
        self.showObservation = showObservation
        self._model = StateObject(wrappedValue: ObservationListViewModel(showList: showObservation == nil)
        )
    }
    
    fileprivate func menuEntries() -> [UIAction] {
        return [
            UIAction(title: String(localized: "ident_from_photo")) { _ in
                
            },
            UIAction(title: String(localized: "record_a_bird")) { _ in
                createFlow.recordSound()
            },
            UIAction(title: String(localized: "photograph_a_plant")) { _ in
                createFlow.takePhoto()
            },
            UIAction(title: String(localized: "create_obs")) { _ in
                createFlow.searchSpecies()
            }
        ]
    }
    
    func configureNavigationItem(item: UINavigationItem, showList: Bool) {
        item.rightBarButtonItems = [
            UIBarButtonItem(title: nil, image: UIImage(named: "add_24"), menu: UIMenu(children: menuEntries())),
            UIBarButtonItem(primaryAction: UIAction(image: UIImage(named: showList ? "map" : "format_list_bulleted")) {action in
                model.showList.toggle()
            })
        ]
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        configureNavigationItem(item: item, showList: true)
    }
    
    var body: some View {
        SwiftUI.Group {
            if(model.showList) {
                List(persistenceController.observations) { observation in
                    ObservationListItemWithImageView(observation: observation)
                        .listRowInsets(.nbInsets)
                        .listRowBackground(Color.secondaryColor)
                        .onTapGesture {
                            navigationController?.pushViewController(ObservationView(occurenceId: observation.id, persistenceController: persistenceController).setUpViewController(), animated: true)
                        }
                }
                .listStyle(.plain)
                .refreshable {
                    await sync()
                }
            } else {
                ObservationMapView(
                    persistenceController: persistenceController,
                    userTrackingMode: $userTrackingMode,
                    initial: showObservation) { observation in
                        navigationController?.pushViewController(ObservationView(occurenceId: observation.id, persistenceController: persistenceController).setUpViewController(), animated: true)
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
        .onReceive(model.$showList) { showList in
            if let item = viewController?.navigationItem {
                configureNavigationItem(item: item, showList: showList)
            }
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error)
        .permissionSettingsDialog(isPresented: $createFlow.showOpenSettings, presenting: createFlow.openSettingsMessage)
    }
    
    private func sync() async {
        do {
            try await client.sync(controller: persistenceController)
        } catch {
            if(errorHandler.handle(error)) {
                bearerToken = nil
            }
        }
    }
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = ObservationPersistenceController(inMemory: true)
        ObservationListView(persistenceController: persistenceController, createFlow: CreateFlowViewModel(persistenceController: persistenceController), showObservation: nil)
    }
}
