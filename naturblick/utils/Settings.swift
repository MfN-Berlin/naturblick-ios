//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit


struct Settings {
    private static let userDefault = UserDefaults.standard
    private static let deviceIdsKey = "deviceIds"
    
    private static func checkOwnDeviceId() {
        let deviceId = deviceId()
        if var deviceIds = userDefault.object(forKey: deviceIdsKey) as? [String] {
            if (!deviceIds.contains(deviceId)) {
                deviceIds.append(deviceId)
                userDefault.set(deviceIds, forKey: deviceIdsKey)
            }
        } else {
            userDefault.set([deviceId], forKey: deviceIdsKey)
        }
    }
    
    static func getAllDeviceIds() -> [String] {
        checkOwnDeviceId()
        if let deviceIds = userDefault.object(forKey: deviceIdsKey) as? [String] {
            return deviceIds
        }
        preconditionFailure("At least my own deviceId must be set")
    }
    
    static func deviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        return deviceId!
    }
}
