//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct NBSound {
    let id: UUID
    
    init(id: UUID = UUID()) {
        self.id = id
    }
    
    var url: URL {
        return URL.documentsDirectory.appendingPathComponent(id.filename(mime: .mp4))
    }
}
