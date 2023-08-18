//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct DeleteOperation: Encodable {
    let occurenceId: UUID
    
    var id: UUID {
        occurenceId
    }
}

extension DeleteOperation {
    enum D {
        static let table = Table("delete_operation")
        static let rowid = Expression<Int64>("rowid")
        static let occurenceId = Expression<UUID>("occurence_id")

        static func setters(id: Int64, operation: DeleteOperation) -> [Setter] {
            [
                rowid <- id,
                occurenceId <- operation.occurenceId,
            ]
        }

        static func instance(row: Row) throws -> DeleteOperation {
            return DeleteOperation(
                occurenceId: try row.get(table[occurenceId])
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        DeleteOperation.D.setters(id: id, operation: self)
    }
}
