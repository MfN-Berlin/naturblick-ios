//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import AVFoundation

@MainActor
class CameraManager : ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var isDenied: Bool = false
    
    init() {
        evaluateAuthorizationStatus()
    }
    
    func askForPermission() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }
    
    func requestAccess() async {
        await AVCaptureDevice.requestAccess(for: .video)
        evaluateAuthorizationStatus()
    }
    
    func evaluateAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        isAuthorized = (status == .authorized)
        isDenied = (status == .denied)
    }
}
