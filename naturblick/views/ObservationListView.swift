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
               }
           ], width: 300);
           
           menuVC.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
           navigationController?.present(menuVC, animated: true)
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
    @State var showDelete: Bool = false
    @State var deleteObservation: IndexSet? = nil
    let showObservation: Observation?
    
    init(persistenceController: ObservationPersistenceController, createFlow: CreateFlowViewModel, showObservation: Observation?) {
        self.persistenceController = persistenceController
        self.createFlow = createFlow
        self.showObservation = showObservation
        self._model = StateObject(wrappedValue: ObservationListViewModel(showList: showObservation == nil)
        )
    }
    
    func configureNavigationItem(item: UINavigationItem, showList: Bool) {
        item.rightBarButtonItems = [ UIBarButtonItem(image: UIImage(named: "add_24"), style: .plain, target: viewController, action: #selector(ObservationListViewController.openMenu)),
         UIBarButtonItem(primaryAction: UIAction(image: UIImage(named: showList ? "map" : "format_list_bulleted")) {action in
             model.showList.toggle()
         })]
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        configureNavigationItem(item: item, showList: true)
    }
    
    var body: some View {
        SwiftUI.Group {
            if(model.showList) {
                List {
                    ForEach(persistenceController.observations) {
                        observation in
                        ObservationListItemWithImageView(observation: observation, persistenceController: persistenceController)
                            .listRowInsets(.nbInsets)
                            .listRowBackground(Color.secondaryColor)
                            .onTapGesture {
                                navigationController?.pushViewController(ObservationViewController(occurenceId: observation.id, persistenceController: persistenceController, flow: createFlow), animated: true)
                            }
                    }
                }
                .animation(.default, value: persistenceController.observations)
                .listStyle(.plain)
                .refreshable {
                    do {
                        try await client.sync(controller: persistenceController)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            } else {
                ObservationMapView(
                    persistenceController: persistenceController,
                    userTrackingMode: $userTrackingMode,
                    initial: showObservation) { observation in
                        navigationController?.pushViewController(ObservationViewController(occurenceId: observation.id, persistenceController: persistenceController, flow: createFlow), animated: true)
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
            try? await client.sync(controller: self.persistenceController)
        }
        .onReceive(model.$showList) { showList in
            if let item = viewController?.navigationItem {
                configureNavigationItem(item: item, showList: showList)
            }
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error, loggedOutHandler: {
            bearerToken = nil
            navigationController?.pushViewController(LoginView(accountViewModel: AccountViewModel()).setUpViewController(), animated: true)
        })
    }
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = ObservationPersistenceController(inMemory: true)
        ObservationListView(persistenceController: persistenceController, createFlow: CreateFlowViewModel(persistenceController: persistenceController), showObservation: nil)
    }
}
