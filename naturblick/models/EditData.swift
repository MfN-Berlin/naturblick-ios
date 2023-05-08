//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct EditData {
    let original: Observation
    var obsType: ObsType
    var speciesId: Int64?
    var coords: Coordinates?
    var details: String

    init(observation: Observation) {
        self.original = observation
        self.obsType = observation.obsType
        self.speciesId = observation.newSpeciesId
        self.details = observation.details ?? ""
        self.coords = observation.coords
    }

    var patch: PatchOperation? {
        let resolvedDetails = self.details == "" ? nil : self.details
        let details = original.details != resolvedDetails ? self.details : nil
        let obsType = original.obsType != self.obsType ? self.obsType : nil
        let coords = original.coords != self.coords ? self.coords : nil

        guard details != nil || obsType != nil || coords != nil else {
            return nil
        }

        return PatchOperation(occurenceId: original.occurenceId, obsType: obsType, coords: coords, details: details)
    }
}
