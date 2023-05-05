//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import CoreLocation
import SQLite

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
    enum D {
        static let observation = Table("observation")
        static let backendObservation = Table("backend_observation")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let obsIdent = Expression<String?>("obs_ident")
        static let obsType = Expression<String>("obs_type")
        static let created = Expression<Date>("created")
        static let createdTz = Expression<String>("created_tz")
        static let species = Expression<Int64?>("species")
        static let mediaId = Expression<UUID?>("media_id")
        static let thumbnailId = Expression<UUID?>("thumbnail_id")
        static let localMediaId = Expression<String?>("local_media_id")
        static let coordsLatitude = Expression<Double?>("coords_latitude")
        static let coordsLongitude = Expression<Double?>("coords_longitude")
        static let individuals = Expression<Int64?>("individuals")
        static let behavior = Expression<String?>("behavior")
        static let details = Expression<String?>("details")

        static func setters(observation: Observation) -> [Setter] {
            [
                occurenceId <- observation.occurenceId,
                obsType <- observation.obsType.rawValue,
                created <- observation.created.date,
                createdTz <- observation.created.tz.identifier,
                species <- observation.newSpeciesId,
                mediaId <- observation.mediaId,
                thumbnailId <- observation.thumbnailId,
                coordsLatitude <- observation.coords?.latitude,
                coordsLongitude <- observation.coords?.longitude,
                individuals <- observation.individuals,
                behavior <- observation.behavior,
                details <- observation.details
            ]
        }

        static func instance(row: Row) throws -> Observation {
            var coords: CLLocationCoordinate2D? = nil
            if let latitude = try row.get(coordsLatitude), let longitude = try row.get(coordsLongitude) {
                coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            return Observation(
                occurenceId: try row.get(occurenceId),
                obsIdent: try row.get(obsIdent),
                obsType: ObsType(rawValue: try row.get(obsType))!, newSpeciesId: try row.get(species),
                created: ZonedDateTime(date: try row.get(created), tz: TimeZone(identifier: try row.get(createdTz))!),
                mediaId: try row.get(mediaId),
                thumbnailId: try row.get(thumbnailId),
                localMediaId: try row.get(localMediaId),
                coords: coords,
                individuals: try row.get(individuals),
                behavior: try row.get(behavior),
                details: try row.get(details)
            )
        }

        static func setters(operation: CreateOperation) -> [Setter] {
            [
                occurenceId <- operation.occurenceId,
                obsType <- operation.obsType.rawValue,
                created <- operation.created.date,
                createdTz <- operation.created.tz.identifier
            ]
        }

        static func setters(operation: PatchOperation) -> [Setter] {
            var setters: [Setter] = []
            if let newDetails = operation.details {
                setters.append(details <- newDetails)
            }
            if let newObsType = operation.obsType {
                setters.append(obsType <- newObsType.rawValue)
            }
            if let latitude = operation.coords?.latitude, let longitude = operation.coords?.longitude {
                setters.append(coordsLatitude <- latitude)
                setters.append(coordsLongitude <- longitude)
            }
            return setters
        }
    }

    var settters: [Setter] {
        Observation.D.setters(observation: self)
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
