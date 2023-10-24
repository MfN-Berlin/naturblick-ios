//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import Photos

extension PHPhotoLibrary {

    static func askForPermission() -> Bool {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined
    }

    static func requestAccess() async {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
    }
}
