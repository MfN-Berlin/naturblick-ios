//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit


struct Settings {
    private static let userDefault = UserDefaults.standard
    private static var allDeviceIds: [String]? = nil
    
    static func updateDeviceIds(persistenceController: ObservationPersistenceController) -> [String] {
        let allDeviceIds = persistenceController.getAllDeviceIds()
        Settings.allDeviceIds = allDeviceIds
        return allDeviceIds
    }
    
    static func getAllDeviceIds(persistenceController: ObservationPersistenceController) -> [String] {
        if let allDeviceIds = Settings.allDeviceIds, !allDeviceIds.isEmpty {
            return allDeviceIds
        } else {
            return updateDeviceIds(persistenceController: persistenceController)
        }
    }
    
    static func deviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        return deviceId!.md5().lowercased()
    }
    
    static func ccByName() -> String {
        return userDefault.string(forKey: "ccByName") ?? "MfN Naturblick"
    }
    
    static func deviceIdHeader(persistenceController: ObservationPersistenceController) -> String {
        return getAllDeviceIds(persistenceController: persistenceController).joined(separator: ",")
    }
}
