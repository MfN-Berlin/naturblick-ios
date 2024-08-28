//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

struct PickerView<Flow>: NavigatableView where Flow: PickerFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    @ObservedObject var flow: Flow
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @StateObject private var locationManager = LocationManager()

    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "pick")) {_ in
            flow.pickCoordinate()
            navigationController?.popViewController(animated: true)
        })
    }
    
    var body: some View {
        Map(coordinateRegion: $flow.region, showsUserLocation: true, userTrackingMode: $userTrackingMode)
            .picker()
            .trackingToggle($userTrackingMode: $userTrackingMode, authorizationStatus: locationManager.permissionStatus)
            .onAppear {
                if locationManager.askForPermission() {
                    locationManager.requestLocation()
                }
            }
    }
}

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        PickerView(flow: EditFlowViewModel(backend: Backend(persistence: ObservationPersistenceController(inMemory: true)), observation: Observation(observation: DBObservation.sampleData, species: nil)))
    }
}
