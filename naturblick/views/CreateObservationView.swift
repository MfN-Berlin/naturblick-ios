//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CreateObservationView: View {
    @Binding var createOperation: CreateOperation
    @StateObject private var locationManager = LocationManager.shared
    @State private var isShowAskForPermission = LocationManager.shared.askForPermission()
    
    var body: some View {
        SwiftUI.Group {
            Form {
                if let location = locationManager.userLocation {
                    Text("\(location.coordinate.longitude); \(location.coordinate.latitude)")
                }
            }
        }.sheet(isPresented: $isShowAskForPermission) {
            LocationRequestView()
        }
    }
}

struct ObservationEditView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(createOperation: .constant(CreateOperation()))
    }
}
