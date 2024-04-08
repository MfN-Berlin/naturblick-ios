//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit
import Photos

class ObservationListViewModel: ObservableObject {
    @Published var showList = true
}

class ObservationListViewController: HostingController<ObservationListView> {
    let persistenceController: ObservationPersistenceController
    let createFlow: CreateFlowViewModel
    init() {
        persistenceController = ObservationPersistenceController()
        createFlow = CreateFlowViewModel(persistenceController: persistenceController, fromList: true)
        let view = ObservationListView(persistenceController: persistenceController, createFlow: createFlow)
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
    @State private var region: MKCoordinateRegion = .defaultRegion
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var createFlow: CreateFlowViewModel
    @StateObject var model = ObservationListViewModel()
    
    fileprivate func extractedFunc() -> [MenuEntry] {
        return [
            MenuEntry(title: String(localized: "ident_from_photo"), image: UIImage(named: "details")!) {
                
            },
            MenuEntry(title: String(localized: "record_a_bird"), image: UIImage(named: "audio24")!) {
                createFlow.recordSound()
            },
            MenuEntry(title: String(localized: "photograph_a_plant"), image: UIImage(named: "photo24")!) {
                    createFlow.takePhoto()
            },
            MenuEntry(title: String(localized: "create_obs"), image: UIImage(named: "logo24")!) {
                createFlow.searchSpecies()
            }
        ]
    }
    
    func configureNavigationItem(item: UINavigationItem, showList: Bool) {
        item.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "add_24"), primaryAction: UIAction(image:  UIImage(named: "add_24")) { action in
                let menuVC = MenuController(entries: extractedFunc());
               menuVC.popoverPresentationController?.barButtonItem = action.sender as? UIBarButtonItem
               navigationController?.present(menuVC, animated: true)
           }), 
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
                Map(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: persistenceController.observations.filter { $0.observation.coords != nil
                    }
                ) { observation in
                    MapAnnotation(coordinate: observation.observation.coords!.location) {
                        MapIcon(mapIcon: observation.species?.group.mapIcon)
                    }
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
        ObservationListView(persistenceController: persistenceController, createFlow: CreateFlowViewModel(persistenceController: persistenceController))
    }
}
