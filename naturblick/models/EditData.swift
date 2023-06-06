//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import MapKit

struct EditData {
    let original: Observation
    var obsType: ObsType
    var speciesId: Int64?
    var coords: Coordinates?
    var details: String
    var individuals: Int64
    
    init(observation: Observation) {
        self.original = observation
        self.obsType = observation.obsType
        self.speciesId = observation.newSpeciesId
        self.details = observation.details ?? ""
        self.coords = observation.coords
        self.individuals = observation.individuals ?? 1
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
        guard details != nil || obsType != nil || coords != nil || individuals != nil else {
            return nil
        }

        return PatchOperation(occurenceId: original.occurenceId, obsType: obsType, coords: coords, details: details, individuals: individuals)
    }
}
