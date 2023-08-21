//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SwiftUI
import Photos

struct NBImage {
    let id: UUID
    let image: UIImage
    
    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
    }
    
    init(id: UUID) async throws {
        self.id = id
        
        let filename = URL.documentsDirectory.appendingPathComponent(id.filename(mime: .jpeg))
        do {
            let data = try Data(contentsOf: filename)
            guard let img = UIImage(data: data) else {
                preconditionFailure("no image data at \(filename)")
            }
            self.image = img
        } catch {
            self.image = try await BackendClient().download(mediaId: id)
            try write()
        }
    }
    
    var url: URL {
        URL.fileURL(id: id, mime: .jpeg)
    }
    
    func write() throws {
        if let data = image.jpegData(compressionQuality: .jpegQuality) {
            try data.write(to: url, options: [.atomic])
        }
    }
    
    func writeToAlbum() throws {
        try write()
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }
    }
}
