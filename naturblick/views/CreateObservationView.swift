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

struct CreateObservationView: View {
    @State private var isPermissionInfoDisplay = false
    @Binding var data: CreateData
    @StateObject private var locationManager = LocationManager()
    @State private var showPicker: Bool = false
    @State private var region: MKCoordinateRegion = .defaultRegion
    
    var body: some View {
        SwiftUI.Group {
            Form {
                if let species = data.species {
                    Text(species.sciname)
                }
                CoordinatesView(coordinates: data.coords)
                    .onTapGesture {
                        showPicker = true
                    }
                NBEditText(label: "Notes", icon: Image("details"), text: $data.details)
                Picker("Behavior", selection: $data.behavior) {
                    ForEach([Behavior].forGroup(group: data.species?.group)) {
                        Text($0.rawValue).tag($0 as Behavior?)
                    }
                }
                IndividualsView(individuals: $data.individuals)
            }
        }.onChange(of: locationManager.userLocation) { location in
            if let location = location {
                let coordinates = Coordinates(location: location)
                if data.coords == nil {
                    data.coords = coordinates
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
                Map(coordinateRegion: $region)
                    .picker()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                region = data.region
                                showPicker = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                data.coords = Coordinates(region: region)
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
        CreateObservationView(data: .constant(CreateData()))
    }
}
