//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Photos

extension PHPhotoLibrary {

    func askForPermission() -> Bool {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined
    }

    func requestAccess() async {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
    }
}
