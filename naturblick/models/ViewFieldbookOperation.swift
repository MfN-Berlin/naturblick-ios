//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)
import Foundation
import SQLite

struct ViewFieldbookOperation: Encodable {
    let deviceIdentifier: String = Settings.deviceId()
    let timestamp: ZonedDateTime;
}

extension ViewFieldbookOperation {
    enum D {
        static let table = Table("view_fieldbook_operation")
        
        static let rowid = Expression<Int64>("rowid")
        static let deviceIdentifier = Expression<String>("device_identifier")
        static let timestamp = Expression<Date>("timestamp")
        static let timestampTz = Expression<String>("timestampTz")

        static func setters(id: Int64, operation: ViewFieldbookOperation) -> [Setter] {
            [
                rowid <- id,
                timestamp <- operation.timestamp.date,
                timestampTz <- operation.timestamp.tz.identifier
            ]
        }
        
        static func instance(row: Row) throws -> ViewFieldbookOperation {
            return ViewFieldbookOperation(
                timestamp: ZonedDateTime(date: try row.get(table[timestamp]), tz: TimeZone(identifier: try row.get(table[timestampTz]))!)
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        ViewFieldbookOperation.D.setters(id: id, operation: self)
    }
}
