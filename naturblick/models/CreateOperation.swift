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
        static let id = Expression<Int64>("rowid")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let obsType = Expression<String>("obs_type")
        static let created = Expression<String>("created")
        static let createdTz = Expression<String>("created_tz")
        static let details = Expression<String?>("details")
    }
}
