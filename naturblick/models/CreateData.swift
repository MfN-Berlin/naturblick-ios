//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI
import MapKit

struct Identified {
    var crop: NBImage
    var result: [SpeciesResult]
}

struct CreateData {
    struct SoundData {
        var sound: NBSound? = nil
        var crop: NBImage? = nil
        var start: CGFloat = 0
        var end: CGFloat = 1
        var result: [SpeciesResult]? = nil
    }
    struct ImageData {
        var image: NBImage? = nil
        var crop: NBImage? = nil
        var result: [SpeciesResult]? = nil
    }
    var occurenceId: UUID = UUID()
    var obsType: ObsType = .manual
    var created: ZonedDateTime = ZonedDateTime()
    var ccByName: String = "MfN Naturblick"
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    var deviceIdentifier: String = Configuration.deviceIdentifier
    var coords: Coordinates? = nil
    var details: String = ""
    var species: SpeciesListItem? = nil
    var individuals: Int64 = 1
    var sound: SoundData = SoundData()
    var image: ImageData = ImageData()

    var identified: Identified? {
        if let result = sound.result, let crop = sound.crop {
            return Identified(crop: crop, result: result)
        } else  if let result = image.result, let crop = image.crop {
            return Identified(crop: crop, result: result)
        } else {
            return nil
        }
    }
    
    var region: MKCoordinateRegion {
        if let coords = self.coords {
            return coords.region
        } else {
            return .defaultRegion
        }
    }
    
    var create: CreateOperation {
        CreateOperation(occurenceId: occurenceId, obsType: obsType, created: created, ccByName: ccByName, appVersion: appVersion, deviceIdentifier: deviceIdentifier, speciesId: species?.speciesId)
    }

    var patch: PatchOperation? {
        guard coords != nil || !details.isEmpty else {
            return nil
        }
        return PatchOperation(occurenceId: occurenceId, obsType: nil, coords: coords, details: details.isEmpty ? nil : details, individuals: individuals)
    }
}
