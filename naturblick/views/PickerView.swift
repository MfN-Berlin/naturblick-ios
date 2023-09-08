//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

class PickerViewController<Flow>: HostingController<PickerView<Flow>> where Flow: PickerFlow {
    let flow: Flow
    init(flow: Flow) {
        self.flow = flow
        super.init(rootView: PickerView(flow: flow))
    }
    
    @objc func pick() {
        flow.pickCoordinate()
        navigationController?.popViewController(animated: true)
    }
}

struct PickerView<Flow>: HostedView where Flow: PickerFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    @ObservedObject var flow: Flow
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @StateObject private var locationManager = LocationManager()

    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .done, target: viewController, action: #selector(PickerViewController<Flow>.pick))
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
        PickerView(flow: EditFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true), observation: Observation(observation: DBObservation.sampleData, species: nil)))
    }
}
