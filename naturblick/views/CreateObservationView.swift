//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CreateObservationView: View {
    @Binding var data: CreateData
    @StateObject private var locationManager = LocationManager.shared
    @State private var isShowAskForPermission = LocationManager.shared.askForPermission()
    
    var body: some View {
        SwiftUI.Group {
            Form {
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
        .sheet(isPresented: $isShowAskForPermission) {
            LocationRequestView()
        }
    }
}

struct ObservationEditView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(data: .constant(CreateData()))
    }
}
