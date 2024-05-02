//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite
import os

struct OldUserData: Decodable {
    let name: String?
    let policy: Bool?
}

extension OldUserData {
    static func getFromOldDB() -> OldUserData? {
        Logger.compat.info("Looking for old user.db")
        do {
            if let fileURL = URL.oldDir?.appendingPathComponent("user.db", isDirectory: false) {
                let connection = try Connection(fileURL.absoluteString)

                if let jsonString = try connection.scalar("SELECT json FROM \"by-sequence\" ORDER BY rowid DESC LIMIT 1") as? String,
                   let jsonData = jsonString.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    return try decoder.decode(OldUserData.self, from: jsonData)
                } else {
                    Logger.compat.info("Failed reading data from user.db")
                    return nil
                }
            } else {
                Logger.compat.info("No user.db file found")
                return nil
            }
        } catch {
            Logger.compat.info("Failed to read from old user DB, \(error)")
            return nil
        }
    }

}
