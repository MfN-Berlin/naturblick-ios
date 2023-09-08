//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

class ObservationListViewController: HostingController<ObservationListView> {
    let persistenceController: ObservationPersistenceController
    let createFlow: CreateFlowViewModel
    init() {
        persistenceController = ObservationPersistenceController()
        createFlow = CreateFlowViewModel(persistenceController: persistenceController)
        let view = ObservationListView(persistenceController: persistenceController, createFlow: createFlow)
        super.init(rootView: view)
        createFlow.setViewController(controller: self)
    }
}

struct ObservationListView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        "Feldbuch"
    }
    
    private let client = BackendClient()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var errorHandler = HttpErrorViewModel()
    @State private var region: MKCoordinateRegion = .defaultRegion
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @State private var showList: Bool = true
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var createFlow: CreateFlowViewModel
    
    var body: some View {
        SwiftUI.Group {
            if(showList) {
                List(persistenceController.observations) { observation in
                    ObservationListItemWithImageView(observation: observation)
                        .listRowInsets(.nbInsets)
                        .listRowBackground(Color.secondaryColor)
                        .onTapGesture {
                            navigationController?.pushViewController(EditObservationViewController(observation: observation, persistenceController: persistenceController), animated: true)
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
                        Image(observation.species?.group.mapIcon ?? "map_undefined_spec")
                            .onTapGesture {
                                navigationController?.pushViewController(EditObservationViewController(observation: observation, persistenceController: persistenceController), animated: true)
                            }
                    }
                }
                .trackingToggle($userTrackingMode: $userTrackingMode, authorizationStatus: locationManager.permissionStatus)
                .onAppear {
                    if(locationManager.askForPermission()) {
                        locationManager.requestLocation()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Menu(content: {
                    Button(action: {
                    }) {
                        HStack {
                            Text("Identify photo from a plant")
                            Image("details")
                        }
                    }
                    Button(action: {
                    }) {
                        HStack {
                            Text("Record a bird sound")
                            Image("microphone")
                        }
                    }
                    Button(action: {
                        createFlow.takePhoto()
                    }) {
                        HStack {
                            Text("Photograph a plant")
                            Image("photo24")
                        }
                    }
                    Button(action: {
                    }) {
                        Text("Create observation")
                        Image("logo24")
                    }
                }, label: {
                    Image(systemName: "plus")
                })
                .tint(.onPrimaryHighEmphasis)
            }
            ToolbarItem(placement: .navigation	) {
                if(showList) {
                    Button(action: {
                        showList = false
                    }) {
                        Image(systemName: "map")
                    }
                    .accessibilityLabel("Show observations on map")
                    .tint(.onPrimaryHighEmphasis)
                } else {
                    Button(action: {
                        showList = true
                    }) {
                        Image(systemName: "list.dash")
                    }
                    .accessibilityLabel("Show in list")
                    .tint(.onPrimaryHighEmphasis)
                }
            }
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error)
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
