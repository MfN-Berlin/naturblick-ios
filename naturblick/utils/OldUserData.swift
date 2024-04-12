//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite


struct OldUserData: Decodable {
    let name: String?
    let policy: Bool?
}

extension OldUserData {
    static func getFromOldDB() -> OldUserData? {
        if let fileURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
           let connection = try? Connection(fileURL.absoluteString),
           let response = try? connection.run("SELECT json FROM \"by-sequence\" ORDER BY rowid DESC LIMIT 1;"),
           let row = response.next(),
           let jsonString = row[0] as? String,
           let jsonData = jsonString.data(using: .utf8)
        {
            let decoder = JSONDecoder()
            return try? decoder.decode(OldUserData.self, from: jsonData)
        } else {
            return nil
        }
    }
}
