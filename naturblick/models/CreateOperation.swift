//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

struct CreateOperation: Encodable {
    let occurenceId: UUID
    let obsType: ObsType
    let created: ZonedDateTime
    let ccByName: String
    let appVersion: String
    let deviceIdentifier: String
    let speciesId: Int64?
    let segmStart: Int64?
    let segmEnd: Int64?
}

extension CreateOperation {
    enum D {
        static let table = Table("create_operation")
        static let rowid = Expression<Int64>("rowid")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let obsType = Expression<String>("obs_type")
        static let created = Expression<Date>("created")
        static let createdTz = Expression<String>("created_tz")
        static let ccByName = Expression<String>("cc_by_name")
        static let appVersion = Expression<String>("app_version")
        static let deviceIdentifier = Expression<String>("device_identifier")
        static let speciesId = Expression<Int64?>("species_id")
        static let segmStart = Expression<Int64?>("segm_start")
        static let segmEnd = Expression<Int64?>("segm_end")

        static func setters(id: Int64, operation: CreateOperation) -> [Setter] {
            [
                rowid <- id,
                occurenceId <- operation.occurenceId,
                obsType <- operation.obsType.rawValue,
                created <- operation.created.date,
                createdTz <- operation.created.tz.identifier,
                ccByName <- operation.ccByName,
                appVersion <- operation.appVersion,
                deviceIdentifier <- operation.deviceIdentifier,
                speciesId <- operation.speciesId,
                segmStart <- operation.segmStart,
                segmEnd <- operation.segmEnd
            ]
        }

        static func instance(row: Row) throws -> CreateOperation {
            return CreateOperation(
                occurenceId: try row.get(table[occurenceId]),
                obsType: ObsType(rawValue: try row.get(table[obsType]))!,
                created: ZonedDateTime(date: try row.get(table[created]), tz: TimeZone(identifier: try row.get(table[createdTz]))!),
                ccByName: try row.get(table[ccByName]),
                appVersion: try row.get(table[appVersion]),
                deviceIdentifier: try row.get(table[deviceIdentifier]),
                speciesId: try row.get(table[speciesId]),
                segmStart: try row.get(table[segmStart]),
                segmEnd: try row.get(table[segmEnd])
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        CreateOperation.D.setters(id: id, operation: self)
    }
}
