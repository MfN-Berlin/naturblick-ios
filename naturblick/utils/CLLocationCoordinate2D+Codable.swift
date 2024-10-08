//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let singleValue = try decoder.singleValueContainer()
        let components = try singleValue.decode([Double].self)
        guard components.count == 2 else {
            throw DecodingError.dataCorruptedError(in: singleValue, debugDescription: "Coordinate array must have exactly 2 elements")
        }
        self.init(latitude: components[1], longitude: components[0])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([longitude as Double, latitude as Double])
    }
}
