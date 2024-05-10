//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit
import os

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
    
    static func oldUrl(obsIdent: String) -> URL? {
        URL.oldRecordings?.appendingPathComponent("\(obsIdent)_Avatar.jpg", isDirectory: false)
    }
    
    private static func findOld(obsIdent: String) -> String? {
        guard let path = oldUrl(obsIdent: obsIdent)?.path else {
            Logger.compat.warning("No path for thumbnail \(obsIdent, privacy: .public)")
            return nil
        }
        
        guard FileManager.default.fileExists(atPath: path) else {
            Logger.compat.warning("No file found at \(path, privacy: .public)")
            return nil
        }
        return path
    }
    
    static func loadOld(occurenceId: UUID, obsIdent: String, persistenceController: ObservationPersistenceController) -> NBThumbnail? {
        Logger.compat.info("Trying to find thumbnail for \(occurenceId, privacy: .public) \(obsIdent, privacy: .public)")
        
        guard let path = NBThumbnail.findOld(obsIdent: obsIdent) else {
            Logger.compat.warning("Could not find thumbnail for \(occurenceId, privacy: .public)")
            return nil
        }
        
        guard let image = UIImage(contentsOfFile: path) else {
            Logger.compat.warning("Could not load thumbnail from \(path, privacy: .public)")
            return nil
        }
        let thumbnail = NBThumbnail(image: image)
        do {
            Logger.compat.info("Create upload operation for thumbnail \(thumbnail.id, privacy: .public), \(occurenceId, privacy: .public)")
            try persistenceController.addMissingThumbnail(occurenceId: occurenceId, thumbnail: thumbnail)
            Logger.compat.info("Deleting \(path, privacy: .public), \(occurenceId, privacy: .public)")
            try? FileManager.default.removeItem(atPath: path)
            Logger.compat.info("Successfully created thumbnail \(thumbnail.id, privacy: .public) from \(path, privacy: .public), \(occurenceId, privacy: .public)")
            return thumbnail
        } catch {
            Logger.compat.warning("Failed to create thumbnail for \(path, privacy: .public), \(occurenceId, privacy: .public): \(error)")
            return nil
        }
    }
}
