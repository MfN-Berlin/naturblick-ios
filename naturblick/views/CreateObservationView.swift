//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

enum CreateObservationAction: Identifiable {
    var id: Self {
        return self
    }
    
    case createImageObservation
    case createSoundObservation
    case createManualObservation
    case createImageFromPhotosObservation
}

class CreateObservationViewController: HostingController<CreateObservationView> {
    let createFlow: CreateFlowViewModel
    public init(createFlow: CreateFlowViewModel) {
        self.createFlow = createFlow
        let view = CreateObservationView(createFlow: createFlow)
        super.init(rootView: view)
        view.holder.viewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(CreateObservationViewController.save))
        if let navigation = navigationController {
            createFlow.takePhoto(navigation: navigation)
        }
    }
    
    @objc func save() {
        if let navigation = navigationController {
            createFlow.saveObservation(navigation: navigation)
        }
    }
}

struct CreateObservationView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    @State private var isPermissionInfoDisplay = false
    @ObservedObject var createFlow: CreateFlowViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @State private var showPicker: Bool = false
    @State private var region: MKCoordinateRegion = .defaultRegion
    
    var body: some View {
        SwiftUI.Group {
            Form {
                if let species = createFlow.data.species {
                    Text(species.sciname)
                }
                CoordinatesView(coordinates: createFlow.data.coords)
                    .onTapGesture {
                        showPicker = true
                    }
                NBEditText(label: "Notes", icon: Image("details"), text: $createFlow.data.details)
                Picker("Behavior", selection: $createFlow.data.behavior) {
                    ForEach([Behavior].forGroup(group: createFlow.data.species?.group)) {
                        Text($0.rawValue).tag($0 as Behavior?)
                    }
                }
                IndividualsView(individuals: $createFlow.data.individuals)
            }
        }.onChange(of: locationManager.userLocation) { location in
            if let location = location {
                let coordinates = Coordinates(location: location)
                if createFlow.data.coords == nil {
                    createFlow.data.coords = coordinates
                    region = coordinates.region
                }
            }
        }
        .onAppear {
            if(locationManager.askForPermission()) {
                locationManager.requestLocation()
            }
        }
        .fullScreenCover(isPresented: $showPicker) {
            NavigationView {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode)
                    .picker()
                    .trackingToggle($userTrackingMode: $userTrackingMode, authorizationStatus: locationManager.permissionStatus)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                region = createFlow.data.region
                                showPicker = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                createFlow.data.coords = Coordinates(region: region)
                                showPicker = false
                            }
                        }
                    }
            }
        }
    }
}

struct CreateObservationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(createFlow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
