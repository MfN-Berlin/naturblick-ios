//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import CoreLocation

struct Observation: Decodable {
    let occurenceId: UUID
    let obsIdent: String?
    let obsType: ObsType
    let newSpeciesId: Int64?
    let created: ZonedDateTime
    let mediaId: UUID?
    let thumbnailId: UUID?
    let localMediaId: String?
    let coords: CLLocationCoordinate2D?
    let individuals: Int64?
    let behavior: String?
    let details: String?
}

extension Observation {
    var dictionaryValue: [String: Any] {
        let keyValueArray: [(String, Any?)] = [
            ("behavior", behavior),
            ("coordsLatitude", coords?.latitude),
            ("coordsLongitude", coords?.longitude),
            ("created", created.date),
            ("createdTz", created.tz.identifier),
            ("details", details),
            ("individuals", individuals),
            ("localMediaId", localMediaId),
            ("obsIdent", obsIdent),
            ("obsType", obsType.rawValue),
            ("occurenceId", occurenceId),
            ("speciesId", newSpeciesId),
            ("thumbnailId", thumbnailId)
        ]
        let nonNullArray: [(String, Any)] = keyValueArray.compactMap { key, value in
            guard let nonNilValue = value else {
                return nil
            }
            return (key, nonNilValue)
        }
        return Dictionary(uniqueKeysWithValues: nonNullArray)
    }
}

extension Observation {
    init(from entity: ObservationEntity){
        occurenceId = entity.occurenceId!
        obsIdent = entity.obsIdent
        obsType = ObsType(rawValue: entity.obsType!)!
        newSpeciesId = entity.speciesId
        created = ZonedDateTime(
            date: entity.created!,
            tz: TimeZone(identifier: entity.createdTz!)!
        )
        mediaId = entity.mediaId
        thumbnailId = entity.thumbnailId
        localMediaId = entity.localMediaId
        if let latitude = entity.coordsLatitude, let longitude = entity.coordsLongitude {
            coords = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(truncating: latitude),
                longitude: CLLocationDegrees(truncating: longitude)
            )
        } else {
            coords = nil
        }
        individuals = entity.individuals
        behavior = entity.behavior
        details = entity.details
    }
}

extension Observation {
    static let sampleData = Observation(
        occurenceId: UUID(),
        obsIdent: nil,
        obsType: .manual,
        newSpeciesId: 1,
        created: ZonedDateTime(),
        mediaId: nil,
        thumbnailId: nil,
        localMediaId: nil,
        coords: nil,
        individuals: nil,
        behavior: nil,
        details: nil
    )
}
