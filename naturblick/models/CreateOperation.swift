//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

struct CreateOperation {
    var occurenceId: UUID = UUID()
    var obsType: ObsType = .manual
    var created: ZonedDateTime = ZonedDateTime()
    var details: String = ""
}

extension CreateOperation {
    enum D {
        static let table = Table("create_operation")
        static let rowid = Expression<Int64>("rowid")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let obsType = Expression<String>("obs_type")
        static let created = Expression<Date>("created")
        static let createdTz = Expression<String>("created_tz")
        static let details = Expression<String>("details")

        static func setters(id: Int64, operation: CreateOperation) -> [Setter] {
            [
                rowid <- id,
                occurenceId <- operation.occurenceId,
                obsType <- operation.obsType.rawValue,
                created <- operation.created.date,
                createdTz <- operation.created.tz.identifier,
                details <- operation.details
            ]
        }

        static func instance(row: Row) throws -> CreateOperation {
            return CreateOperation(
                occurenceId: try row.get(occurenceId),
                obsType: ObsType(rawValue: try row.get(obsType))!,
                created: ZonedDateTime(date: try row.get(created), tz: TimeZone(identifier: try row.get(createdTz))!),
                details: try row.get(details)
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        CreateOperation.D.setters(id: id, operation: self)
    }
}
