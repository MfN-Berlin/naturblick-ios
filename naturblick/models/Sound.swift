//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct Sound {
    let id: UUID
    
    init(id: UUID = UUID()) {
        self.id = id
    }
    
    var url: URL {
        let fileName = "naturblick_\(id.uuidString).mp4"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return docDirURL.appendingPathComponent(fileName)
    }
}
