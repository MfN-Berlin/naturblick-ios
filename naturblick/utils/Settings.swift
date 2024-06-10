//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit


struct Settings {
    private static let userDefault = UserDefaults.standard
    private static var allDeviceIds: [String]? = nil
    
    static func updateDeviceIds() -> [String] {
        let persistenceController = ObservationPersistenceController()
        let allDeviceIds = persistenceController.getAllDeviceIds()
        Settings.allDeviceIds = allDeviceIds
        return allDeviceIds
    }
    
    static func getAllDeviceIds() -> [String] {
        if let allDeviceIds = Settings.allDeviceIds {
            return allDeviceIds
        } else {
            return updateDeviceIds()
        }
    }
    
    static func deviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        return deviceId!.md5().lowercased()
    }
    
    static func ccByName() -> String {
        return userDefault.string(forKey: "ccByName") ?? "MfN Naturblick"
    }
    
    static func deviceIdHeader() -> String {
        return getAllDeviceIds().joined(separator: ",")
    }
}
