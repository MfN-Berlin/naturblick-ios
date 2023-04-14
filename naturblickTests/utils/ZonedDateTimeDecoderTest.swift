//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import XCTest
@testable import naturblick

final class ZonedDateTimeDecoderTest: XCTestCase {
    private let decoder = JSONDecoder()
    func testParseValidZonedDateTime() throws {
        let decoded = try decoder.decode(ZonedDateTime.self, from: "\"2007-12-03T10:15:30+01:00[Europe/Paris]\"".data(using: .utf8)!)
        XCTAssertEqual(decoded, ZonedDateTime(date: Date(timeIntervalSince1970: 1196673330), tz: TimeZone(identifier: "Europe/Paris")!))
    }

    func testParseValidZonedDateTimeWithDecimals() throws {
        let decoded = try decoder.decode(ZonedDateTime.self, from: "\"2007-12-03T10:15:30.456+01:00[Europe/Paris]\"".data(using: .utf8)!)
        let date = Date(timeIntervalSince1970: 1196673330).advanced(by: 0.456)
        XCTAssertEqual(date.timeIntervalSince1970, decoded.date.timeIntervalSince1970, accuracy: 0.00000001)
        XCTAssertEqual(decoded.tz, TimeZone(identifier: "Europe/Paris"))
    }

    func testFailParseDateTime() throws {
        XCTAssertThrowsError(try decoder.decode(ZonedDateTime.self, from: "\"2007-12-03T10:15:30+01:00\"".data(using: .utf8)!)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail()
            }
        }
    }

    func testFailParseInvalidTimezone() throws {
        XCTAssertThrowsError(try decoder.decode(ZonedDateTime.self, from: "\"2007-12-03T10:15:30+01:00[Moon/Paris]\"".data(using: .utf8)!)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail()
            }
        }
    }

    func testFailParseInvalidDateTime() throws {
        XCTAssertThrowsError(try decoder.decode(ZonedDateTime.self, from: "\"2007-12-03:30+01:00[Europe/Paris]\"".data(using: .utf8)!)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail()
            }
        }
    }
}
