//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct TimeZoneVertex: Identifiable {
    let id: Int64
    let polygonId: Int64
    let latitude: Double
    let longitude: Double
}

extension TimeZoneVertex {
    struct D {
        static let table = Table("time_zone_vertex")
        static let id = Expression<Int64>("rowid")
        static let polygonId = Expression<Int64>("polygon_id")
        static let latitude = Expression<Double>("latitude")
        static let longitude = Expression<Double>("longitude")
        
        static func instance(row: Row) throws -> TimeZoneVertex {
            return TimeZoneVertex(
                id: try row.get(id),
                polygonId: try row.get(polygonId),
                latitude: try row.get(latitude),
                longitude: try row.get(longitude)
            )
        }
    }
}
