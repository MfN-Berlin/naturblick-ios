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
    
    init(createFlow: CreateFlowViewModel) {
        self.createFlow = createFlow
        super.init(rootView: CreateObservationView(createFlow: createFlow))
    }
    @objc func saveObservation() {
        createFlow.saveObservation()
    }
}

struct CreateObservationView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: viewController, action: #selector(CreateObservationViewController.saveObservation))
    }
    
    @State private var isPermissionInfoDisplay = false
    @ObservedObject var createFlow: CreateFlowViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    var body: some View {
        SwiftUI.Group {
            Form {
                if let species = createFlow.data.species {
                    Text(species.sciname)
                }
                CoordinatesView(coordinates: createFlow.data.coords)
                    .onTapGesture {
                        navigationController?.pushViewController(PickerViewController(flow: createFlow), animated: true)
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
                    createFlow.resetRegion()
                }
            }
        }
        .onAppear {
            if(locationManager.askForPermission()) {
                locationManager.requestLocation()
            }
        }
    }
}

struct CreateObservationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(createFlow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
