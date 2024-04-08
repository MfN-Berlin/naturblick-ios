//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit

struct NBThumbnail {
    let id: UUID
    let image: UIImage
    
    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
        if let data = image.jpegData(compressionQuality: .jpegQuality) {
            let url = URL(string: Configuration.backendUrl + "/media/\(id)")!
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
        }
    }
    
    init(id: UUID) async throws {
        self.id = id
        self.image = try await BackendClient().downloadCached(mediaId: id)
    }
    
    var url: URL {
        NBThumbnail.url(id: id)
    }
    
    private static func url(id: UUID) -> URL {
        URL.fileURL(id: id, mime: .jpeg)
    }
}
