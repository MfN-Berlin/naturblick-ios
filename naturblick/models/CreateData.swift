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
    var occurenceId: UUID = UUID()
    var created: ZonedDateTime = ZonedDateTime()
    var ccByName: String = Settings.ccByName()
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    var deviceIdentifier: String = Settings.deviceId()
    var coords: Coordinates? = nil
    var details: String = ""
    var species: SpeciesListItem? = nil
    var individuals: Int64 = 1
    var behavior: Behavior? = nil
    var sound: SoundData = SoundData()
    var image: ImageData = ImageData()

    var obsType: ObsType {
        if image.image != nil && species != nil {
            return .image
        } else if image.image != nil {
            return .unidentifiedimage
        } else if sound.sound != nil && species != nil {
            return .audio
        } else if sound.sound != nil {
            return .unidentifiedaudio
        } else {
            return .manual
        }
    }
    
    var identified: Identified? {
        if let identified = sound.identified {
            return identified
        } else if let identified = image.identified {
            return identified
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
        var mediaId: UUID? = nil
        var thumbnailId: UUID? = nil
        
        if image.image != nil {
            mediaId = image.image?.id
            thumbnailId = image.crop?.id
        } else if sound.sound != nil {
            mediaId = sound.sound?.id
            thumbnailId = sound.crop?.id
        }

        guard coords != nil || !details.isEmpty || mediaId != nil || thumbnailId != nil || behavior != nil else {
            return nil
        }
        return PatchOperation(occurenceId: occurenceId, obsType: nil, coords: coords, details: details.isEmpty ? nil : details, individuals: individuals, mediaId: mediaId, thumbnailId: thumbnailId, newSpeciesId: nil, behavior: behavior)
    }
}
