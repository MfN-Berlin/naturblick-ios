//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import os

func syncOldSyncOperations() async throws {
    guard let fileURL = URL.syncOperationsFile else {
        Logger.compat.info("No old syncs")
        return
    }
    
    if FileManager().fileExists(atPath: fileURL.path) {
        let json = try Data(contentsOf: fileURL)
        if let jsonStr = String(data: json, encoding: .utf8) {
            
            let newJsonStr = """
                {
                    "operations" : \(jsonStr)
                }
            """
            
            let url = URL(string: Configuration.backendUrl + "obs/sync")!
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            
            request.httpBody = newJsonStr.data(using: .utf8)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 30
            request.setAuthHeader(bearerToken: await Keychain.shared.token)
     
            let downloader: HTTPDownloader = URLSession.shared
            let _ = try await downloader.http(request: request)
            Logger.compat.info("Successfully send old syncOperations.json")
        }
    }
}


