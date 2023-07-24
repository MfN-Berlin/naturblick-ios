//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SwiftUI

struct NBImage {
    let id: UUID
    let image: UIImage
    
    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
    }
    
    init(id: UUID) async throws {
        self.id = id
        
        let filename = getDocumentsDirectory().appendingPathComponent(id.filename(mime: .jpeg))
        do {
            let data = try Data(contentsOf: filename)
            guard let img = UIImage(data: data) else {
                preconditionFailure("no image data at \(filename)")
            }
            self.image = img
        } catch {
            self.image = try await BackendClient().downloadCached(mediaId: id)
            write()
        }
    }
    
    func write() {
        if let data = image.jpegData(compressionQuality: 0.81) {
            let filename = getDocumentsDirectory().appendingPathComponent(id.filename(mime: .jpeg))
            try? data.write(to: filename, options: [.withoutOverwriting])
        }
    }
}
