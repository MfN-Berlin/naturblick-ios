//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct CreateData {
    var occurenceId: UUID = UUID()
    var obsType: ObsType = .manual
    var created: ZonedDateTime = ZonedDateTime()
    var ccByName: String = "MfN Naturblick"
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    var deviceIdentifier: String = Configuration.deviceIdentifier
    var coords: Coordinates? = nil
    var details: String = ""

    var create: CreateOperation {
        CreateOperation(occurenceId: occurenceId, obsType: obsType, created: created, ccByName: ccByName, appVersion: appVersion, deviceIdentifier: deviceIdentifier)
    }

    var patch: PatchOperation? {
        guard coords != nil || !details.isEmpty else {
            return nil
        }
        return PatchOperation(occurenceId: occurenceId, obsType: nil, coords: coords, details: details.isEmpty ? nil : details)
    }
}