//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import CoreLocation

struct Observation: Decodable {
    let occurenceId: UUID
    let obsIdent: String?
    let obsType: ObsType
    let newSpeciesId: Int?
    let created: ZonedDateTime
    let mediaId: UUID?
    let thumbnailId: UUID?
    let localMediaId: String?
    let coords: CLLocationCoordinate2D?
    let individuals: Int?
    let behavior: String?
    let details: String?
}
