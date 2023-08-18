//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

struct ObservationListView: View {
    
    let initialCreateAction: CreateObservationAction?
    private let client = BackendClient()
    @StateObject private var locationManager = LocationManager()
    @StateObject var persistenceController = ObservationPersistenceController()
    @StateObject private var errorHandler = HttpErrorViewModel()
    @State private var region: MKCoordinateRegion = .defaultRegion
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @State private var showList: Bool = true
    @State var didRunOnce: Bool = false
    @State var createAction: CreateObservationAction? = nil
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    
    var body: some View {
        SwiftUI.Group {
            if(showList) {
                List(persistenceController.observations) { observation in
                    NavigationLink(destination: ObservationView(observation: observation, controller: persistenceController)) {
                        ObservationListItemWithImageView(observation: observation)
                    }
                }
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
                        NavigationLink(
                            destination: ObservationView(observation: observation, controller: persistenceController)
                        ) {
                            Image(observation.species?.group.mapIcon ?? "map_undefined_spec")
                        }
                        .foregroundColor(.red)
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
        .navigationTitle("Feldbuch")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Menu(content: {
                    Button(action: {
                        createAction = .createImageFromPhotosObservation
                    }) {
                        HStack {
                            Text("Identify photo from a plant")
                            Image("details")
                        }
                    }
                    Button(action: {
                        createAction = .createSoundObservation
                    }) {
                        HStack {
                            Text("Record a bird sound")
                            Image("microphone")
                        }
                    }
                    Button(action: {
                        createAction = .createImageObservation
                    }) {
                        HStack {
                            Text("Photograph a plant")
                            Image("photo24")
                        }
                    }
                    Button(action: {
                        createAction = .createManualObservation
                    }) {
                        Text("Create observation")
                        Image("logo24")
                    }
                }, label: {
                    Image(systemName: "plus")
                })
            }
            ToolbarItem(placement: .navigation	) {
                if(showList) {
                    Button(action: {
                        showList = false
                    }) {
                        Image(systemName: "map")
                    }
                    .accessibilityLabel("Show observations on map")
                } else {
                    Button(action: {
                        showList = true
                    }) {
                        Image(systemName: "list.dash")
                    }
                    .accessibilityLabel("Show in list")
                }
            }
        }
        .sheet(item: $createAction) { action in
            NavigationView {
                CreateFlowView(action: action, persistenceController: persistenceController)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                createAction = nil
                            }
                        }
                    }
            }
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error)
        .onAppear {
            if !didRunOnce {
                if let initial = initialCreateAction {
                    createAction = initial
                }
                didRunOnce = true
            }
        }
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
        ObservationListView(initialCreateAction: nil)
    }
}
