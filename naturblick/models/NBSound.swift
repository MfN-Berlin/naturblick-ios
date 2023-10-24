//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct NBSound {
    let id: UUID
    
    init() {
        self.id = UUID()
    }
    
    init(id: UUID) async throws {
        self.id = id
        let path = NBSound.url(id: id).path
        if !FileManager.default.fileExists(atPath: path) {
            let data = try await BackendClient().downloadSound(mediaId: id)
            FileManager.default.createFile(atPath: path, contents: data)
        }
    }
    
    var url: URL {
        return NBSound.url(id: id)
    }
        
    static func url(id: UUID) -> URL {
        return URL.documentsDirectory.appendingPathComponent(id.filename(mime: .mp4))
    }
}
