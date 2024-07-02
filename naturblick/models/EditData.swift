//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import MapKit

struct EditData {
    let original: DBObservation
    var obsType: ObsType
    var species: SpeciesListItem?
    var coords: Coordinates?
    var details: String
    var individuals: Int64
    var thumbnail: NBThumbnail?
    var behavior: Behavior
    
    init(observation: Observation) {
        self.original = observation.observation
        self.obsType = observation.observation.obsType
        self.species = observation.species?.listItem
        self.details = observation.observation.details ?? ""
        self.coords = observation.observation.coords
        self.individuals = observation.observation.individuals ?? 1
        self.behavior = observation.observation.behavior ?? .notSet
    }

    var speciesChanged: Bool {
        species?.speciesId != original.newSpeciesId
    }
    
    var region: MKCoordinateRegion {
        if let coords = self.coords {
            return coords.region
        } else {
            return .defaultRegion
        }
    }
    
    var patch: PatchOperation? {
        let resolvedDetails = self.details == "" ? nil : self.details
        let details = original.details != resolvedDetails ? self.details : nil
        let obsType = original.obsType != self.obsType ? self.obsType : nil
        let coords = original.coords != self.coords ? self.coords : nil
        let individuals = original.individuals != self.individuals ? self.individuals : nil
        let speciesId = speciesChanged ? self.species?.speciesId : nil
        let thumbnailId = thumbnail?.id != original.thumbnailId ? thumbnail?.id : nil
        let originalBehavior: Behavior = original.behavior ?? .notSet
        let behavior = originalBehavior != self.behavior ? self.behavior : nil
        guard details != nil || obsType != nil || coords != nil || individuals != nil || speciesId != nil || thumbnailId != nil || behavior != nil else {
            return nil
        }

        return PatchOperation(occurenceId: original.occurenceId, obsType: obsType, coords: coords, details: details, individuals: individuals, mediaId: nil, localMediaId: nil, thumbnailId: thumbnailId, newSpeciesId: speciesId, behavior: behavior)
    }
    
    var hasChanged: Bool {
        patch != nil
    }
}
