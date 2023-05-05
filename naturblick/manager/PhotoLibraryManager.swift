//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import PhotosUI

@MainActor
class PhotoLibraryManager : ObservableObject {
    
    @Published var isAuthorized: Bool = false
    @Published var isDenied: Bool = false
    
    init() {
        evaluateAuthorizationStatus()
    }
    
    func askForPermission() -> Bool {
        PHPhotoLibrary.authorizationStatus(for: .addOnly) == .notDetermined
    }
    
    func requestAccess() async {
        await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        evaluateAuthorizationStatus()
    }
    
 
    func evaluateAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        isAuthorized = (status == .authorized)
        isDenied = (status == .denied)
    }
}
