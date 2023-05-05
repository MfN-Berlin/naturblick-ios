//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct ZonedDateTime: Equatable {
    let date: Date
    let tz: TimeZone
}

extension ZonedDateTime {
    init() {
        date = Date()
        tz = TimeZone.current
    }
}

extension ZonedDateTime: Codable {
    static func dateFormatterFractionalSeconds() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }

    static let dateFormatter = ISO8601DateFormatter()

    init(from decoder: Decoder) throws {
        let singleValue = try decoder.singleValueContainer()
        let components = try singleValue.decode(String.self).components(separatedBy: "[")
        if(components.count == 2) {
            let dateStr = String(components[0])
            let tzStr = String(components[1].dropLast())
            let date = ZonedDateTime.dateFormatter.date(from: dateStr) ?? ZonedDateTime.dateFormatterFractionalSeconds().date(from: dateStr)
            let tz = TimeZone(identifier: tzStr)
            guard let validDate = date else {
                throw DecodingError.dataCorrupted(.init(codingPath: singleValue.codingPath, debugDescription: "\(dateStr) is not a valid ISO 8601"))
            }
            guard let validTz = tz else {
                throw DecodingError.dataCorrupted(.init(codingPath: singleValue.codingPath, debugDescription: "\(tzStr) is not a valid time zone"))
            }
            self.date = validDate
            self.tz = validTz
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: singleValue.codingPath, debugDescription: "Not a valid java ZonedDateTime representation with timezone")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        let zonedDateTime = "\(ZonedDateTime.dateFormatter.string(from: date))[\(tz.identifier)]"
        var container = encoder.singleValueContainer()
        try container.encode(zonedDateTime)
    }
}
