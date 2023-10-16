//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import CoreLocation
import SQLite

struct PatchOperation: Encodable {
    let occurenceId: UUID
    let obsType: ObsType?
    let coords: Coordinates?
    let details: String?
    let individuals: Int64?
    let mediaId: UUID?
    let localMediaId: String?
    let thumbnailId: UUID?
    let newSpeciesId: Int64?
    let behavior: Behavior?
}

extension PatchOperation {
    enum D {
        static let table = Table("patch_operation")
        static let rowid = Expression<Int64>("rowid")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let obsType = Expression<String?>("obs_type")
        static let coordsLatitude = Expression<Double?>("coords_latitude")
        static let coordsLongitude = Expression<Double?>("coords_longitude")
        static let details = Expression<String?>("details")
        static let individuals = Expression<Int64?>("individuals")
        static let mediaId = Expression<UUID?>("media_id")
        static let localMediaId = Expression<String?>("local_media_id")
        static let thumbnailId = Expression<UUID?>("thumbnail_id")
        static let speciesId = Expression<Int64?>("species_id")
        static let behavior = Expression<String?>("behavior")
        
        static func setters(id: Int64, operation: PatchOperation) -> [Setter] {
            [
                rowid <- id,
                occurenceId <- operation.occurenceId,
                obsType <- operation.obsType?.rawValue,
                coordsLatitude <- operation.coords?.latitude,
                coordsLongitude <- operation.coords?.longitude,
                details <- operation.details,
                individuals <- operation.individuals,
                mediaId <- operation.mediaId,
                localMediaId <- operation.localMediaId,
                thumbnailId <- operation.thumbnailId,
                speciesId <- operation.newSpeciesId,
                behavior <- operation.behavior?.rawValue
            ]
        }

        static func instance(row: Row) throws -> PatchOperation {
            var type: ObsType? = nil
            if let rawValue: String = try row.get(table[obsType]) {
                type = ObsType(rawValue: rawValue)
            }
            var coords: Coordinates? = nil
            if let latitude = try row.get(table[coordsLatitude]), let longitude = try row.get(table[coordsLongitude]) {
                coords = Coordinates(latitude: latitude, longitude: longitude)
            }
            var behaviorEnum: Behavior? = nil
            if let behaviorStr = try row.get(behavior) {
                behaviorEnum = Behavior(rawValue: behaviorStr)
            }
            
            return PatchOperation(
                occurenceId: try row.get(table[occurenceId]),
                obsType:  type,
                coords: coords,
                details: try row.get(table[details]),
                individuals: try row.get(table[individuals]),
                mediaId: try row.get(table[mediaId]),
                localMediaId: try row.get(table[localMediaId]),
                thumbnailId: try row.get(table[thumbnailId]),
                newSpeciesId: try row.get(table[speciesId]),
                behavior: behaviorEnum
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        PatchOperation.D.setters(id: id, operation: self)
    }
}
