//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI
import MapKit

struct CreateData {
    struct SoundData {
        struct Result {
            var species: [SpeciesResult] = []
            var selected: Int? = nil
            var thumbnailId: UUID
        }
        var sound: Sound? = nil
        var start: CGFloat = 0
        var end: CGFloat = 1
        var result: Result? = nil
    }
    struct ImageData {
        var mediaId: UUID? = nil
        var img: UIImage? = nil
        var crop: UIImage? = nil
    }
    var occurenceId: UUID = UUID()
    var obsType: ObsType = .manual
    var created: ZonedDateTime = ZonedDateTime()
    var ccByName: String = "MfN Naturblick"
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    var deviceIdentifier: String = Configuration.deviceIdentifier
    var coords: Coordinates? = nil
    var details: String = ""
    var species: Species? = nil
    var individuals: Int64 = 1
    var sound: SoundData = SoundData()
    var image: ImageData = ImageData()
    
    var region: MKCoordinateRegion {
        if let coords = self.coords {
            return coords.region
        } else {
            return .defaultRegion
        }
    }
    
    var create: CreateOperation {
        CreateOperation(occurenceId: occurenceId, obsType: obsType, created: created, ccByName: ccByName, appVersion: appVersion, deviceIdentifier: deviceIdentifier, speciesId: species?.id)
    }

    var patch: PatchOperation? {
        guard coords != nil || !details.isEmpty else {
            return nil
        }
        return PatchOperation(occurenceId: occurenceId, obsType: nil, coords: coords, details: details.isEmpty ? nil : details, individuals: individuals)
    }
}
