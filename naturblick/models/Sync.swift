//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)
import Foundation
import SQLite

struct Sync {
    let syncId: Int64?
}

extension Sync {
    enum D {
        static let sync = Table("sync")
        static let syncId = Expression<Int64?>("sync_id")
        
        static func setters(sync: Sync) -> [Setter] {
            [
                syncId <- sync.syncId
            ]
        }

        static func instance(row: Row) throws -> Sync {
            return Sync(
                syncId: try row.get(syncId)
            )
        }
    }

    var settters: [Setter] {
        Sync.D.setters(sync: self)
    }
}
