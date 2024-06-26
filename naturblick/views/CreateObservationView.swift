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

struct CreateObservationView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var hideNavigationBarShadow: Bool = true
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "save")) {_ in
            viewController?.dismiss(animated: true)
            createFlow.saveObservation()
        })
    }
    
    @State private var isPermissionInfoDisplay = false
    @ObservedObject var createFlow: CreateFlowViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .none
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                createFlow.speciesAvatar
                    .avatar()
                    .padding(.trailing, .defaultPadding)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: .zero) {
                    Text("species")
                        .caption(color: .onSecondarySignalLow)
                    if let species = createFlow.data.species {
                        Text(species.speciesName ?? species.sciname)
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    } else {
                        Text("unknown_species")
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    }
                }
            }
            Divider()
            HStack {
                Image(decorative: "location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("location")
                        .caption(color: .onSecondarySignalLow)
                    CoordinatesView(coordinates: createFlow.data.coords)
                }
                Spacer()
                Button("change") {
                    navigationController?.pushViewController(PickerView(flow: createFlow).setUpViewController(), animated: true)
                }
                .buttonStyle(ChangeSpeciesButton())
            }
            Divider()
            HStack {
                Image(decorative: "number24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("number")
                        .caption(color: .onSecondarySignalLow)
                    IndividualsView(individuals: $createFlow.data.individuals)
                }
            }
            Divider()
            HStack {
                Image(decorative: "location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("behavior")
                        .caption(color: .onSecondarySignalLow)
                    Picker("behavior", selection: $createFlow.data.behavior) {
                        Text("none").tag(nil as Behavior?)
                        ForEach([Behavior].forGroup(group: createFlow.data.species?.group)) {
                            Text($0.rawValue).tag($0 as Behavior?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            Divider()
            HStack {
                Image(decorative: "details")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("notes")
                        .caption(color: .onSecondarySignalLow)
                    TextField("edit_notes", text: $createFlow.data.details)
                }
            }
            Spacer()
        }
        .padding(.defaultPadding)
        .onChange(of: locationManager.userLocation) { location in
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
