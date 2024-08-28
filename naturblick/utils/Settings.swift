//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit


struct Settings {
    private static let userDefault = UserDefaults.standard
    
    static func deviceId() -> String {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        return deviceId!.md5().lowercased()
    }
    
    static func ccByName() -> String {
        return userDefault.string(forKey: "ccByName") ?? "MfN Naturblick"
    }

}
