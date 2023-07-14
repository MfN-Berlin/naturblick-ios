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
    var thumbnailId: UUID?
    
    init(observation: DBObservation, species: Species?) {
        self.original = observation
        self.obsType = observation.obsType
        self.species = species?.listItem
        self.details = observation.details ?? ""
        self.coords = observation.coords
        self.individuals = observation.individuals ?? 1
        self.thumbnailId = observation.thumbnailId
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
        let thumbnailId = thumbnailId != original.thumbnailId ? thumbnailId : nil
        guard details != nil || obsType != nil || coords != nil || individuals != nil || speciesId != nil || thumbnailId != nil else {
            return nil
        }

        return PatchOperation(occurenceId: original.occurenceId, obsType: obsType, coords: coords, details: details, individuals: individuals, mediaId: nil, thumbnailId: thumbnailId, newSpeciesId: speciesId)
    }
}
