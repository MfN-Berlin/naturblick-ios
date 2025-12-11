//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)
import Foundation
import SQLite

struct ViewPortraitOperation: Encodable {
    let deviceIdentifier: String = Settings.deviceId()
    let speciesId: Int64
    let timestamp: ZonedDateTime
}


extension ViewPortraitOperation {
    enum D {
        static let table = Table("view_portrait_operation")
        
        static let rowid = Expression<Int64>("rowid")
        static let deviceIdentifier = Expression<String>("device_identifier")
        static let speciesId = Expression<Int64>("species_id")
        static let timestamp = Expression<Date>("timestamp")
        static let timestampTz = Expression<String>("timestampTz")

        static func setters(id: Int64, operation: ViewPortraitOperation) -> [Setter] {
            [
                rowid <- id,
                speciesId <- operation.speciesId,
                timestamp <- operation.timestamp.date,
                timestampTz <- operation.timestamp.tz.identifier
            ]
        }
        
        static func instance(row: Row) throws -> ViewPortraitOperation {
            return ViewPortraitOperation(
                speciesId: try row.get(table[speciesId]),
                timestamp: ZonedDateTime(date: try row.get(table[timestamp]), tz: TimeZone(identifier: try row.get(table[timestampTz]))!)
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        ViewPortraitOperation.D.setters(id: id, operation: self)
    }
}
