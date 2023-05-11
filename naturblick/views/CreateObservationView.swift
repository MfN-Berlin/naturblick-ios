//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

enum ObservationAction {
    case createImageObservation
    case createManualObservation
}

struct CreateObservationView: View {
    
    let obsAction: ObservationAction
    @Binding var data: CreateData
    @StateObject private var locationManager = LocationManager.shared
    @State private var isShowAskForPermission = LocationManager.shared.askForPermission()
    @State private var createImage = false
    
    var body: some View {
        SwiftUI.Group {
            Form {
                if let species = data.species {
                    Text(species.sciname)
                }
                if let latitude = data.coords?.latitude,
                    let longitude = data.coords?.longitude {
                    Text("\(longitude), \(latitude)")
                }
                NBEditText(label: "Notes", iconAsset: "details", text: $data.details)
            }
        }.onChange(of: locationManager.userLocation) { location in
            if let location = location {
                data.coords = Coordinates(location: location)
            }
        }
        .sheet(isPresented: $createImage) {
            TakePhotoView(isPresented: $createImage, data: $data)
        }
        .sheet(isPresented: $isShowAskForPermission) {
            LocationRequestView()
        }
        .onAppear {
            if (obsAction == .createImageObservation) {
                createImage = true
            }
        }
    }
}

struct ObservationEditView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(obsAction: .createManualObservation, data: .constant(CreateData()))
    }
}
