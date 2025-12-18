//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)
import Foundation
import SQLite

struct ViewCharactersOperation: Encodable {
    let deviceIdentifier: String = Settings.deviceId()
    let groupname: String
    let timestamp: ZonedDateTime
    
    enum CodingKeys: String, CodingKey {
        case deviceIdentifier
        case groupname = "group"
        case timestamp
    }
}


extension ViewCharactersOperation {
    enum D {
        static let table = Table("view_characters_operation")
        
        static let rowid = Expression<Int64>("rowid")
        static let deviceIdentifier = Expression<String>("device_identifier")
        static let groupname = Expression<String>("groupname")
        static let timestamp = Expression<Date>("timestamp")
        static let timestampTz = Expression<String>("timestampTz")

        static func setters(id: Int64, operation: ViewCharactersOperation) -> [Setter] {
            [
                rowid <- id,
                groupname <- operation.groupname,
                timestamp <- operation.timestamp.date,
                timestampTz <- operation.timestamp.tz.identifier
            ]
        }
        
        static func instance(row: Row) throws -> ViewCharactersOperation {
            return ViewCharactersOperation(
                groupname: try row.get(table[groupname]),
                timestamp: ZonedDateTime(date: try row.get(table[timestamp]), tz: TimeZone(identifier: try row.get(table[timestampTz]))!)
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        ViewCharactersOperation.D.setters(id: id, operation: self)
    }
}
