//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var permissionStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
    func askForPermission() -> Bool {
        manager.authorizationStatus == .notDetermined
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        permissionStatus = status
    }
}
