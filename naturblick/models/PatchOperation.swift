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
    let thumbnailId: UUID?
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
        static let thumbnailId = Expression<UUID?>("thumbnail_id")

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
                thumbnailId <- operation.thumbnailId
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
            return PatchOperation(
                occurenceId: try row.get(table[occurenceId]),
                obsType:  type,
                coords: coords,
                details: try row.get(table[details]),
                individuals: try row.get(table[individuals]),
                mediaId: try row.get(table[mediaId]),
                thumbnailId: try row.get(table[thumbnailId])
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        PatchOperation.D.setters(id: id, operation: self)
    }
}
