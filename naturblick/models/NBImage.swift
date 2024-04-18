//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SwiftUI
import Photos

struct NBImage {
    let id: UUID
    let localIdentifier: String?
    let image: UIImage
    
    init(id: UUID = UUID(), image: UIImage, localIdentifier: String) {
        self.id = id
        self.image = image
        self.localIdentifier = localIdentifier
    }
    
    init(id: UUID = UUID(), image: UIImage) async throws {
        self.id = id
        self.image = image
        self.localIdentifier = try await NBImage.writeToAlbum(id: id, image: image)
    }
    
    private static func fetchImage(localIdentifier: String) async -> UIImage? {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined {
            await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        }
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
            return await withCheckedContinuation { continuation in
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                let manager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.version = .original
                if let object = asset.firstObject {
                    manager.requestImageDataAndOrientation(for: object, options: options) {data,_,_,_ in
                        if let data = data, let image = UIImage(data: data) {
                            continuation.resume(returning: image)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
                } else {
                    continuation.resume(returning: nil)
                }
            }
        } else {
            return nil
        }
    }
    
    init(id: UUID, localIdentifier: String?) async throws {
        self.id = id
        self.localIdentifier = localIdentifier
        let path = NBImage.url(id: id).path
        if FileManager.default.fileExists(atPath: path), let image = UIImage(contentsOfFile: path) {
            self.image = image
        } else if let local = localIdentifier, let image = await NBImage.fetchImage(localIdentifier: local) {
            self.image = image
        } else {
            self.image = try await BackendClient().downloadCached(mediaId: id)
        }
    }
    
    var url: URL {
        NBImage.url(id: id)
    }
    
    private static func url(id: UUID) -> URL {
        URL.fileURL(id: id, mime: .jpeg)
    }
    
    private static func write(id: UUID, image: UIImage) throws {
        if let data = image.jpegData(compressionQuality: .jpegQuality) {
            try data.write(to: url(id: id), options: [.atomic])
        }
    }
    
    private static func writeToAlbum(id: UUID, image: UIImage) async throws -> String?{
        try write(id: id, image: image)
        var localIdentifier: String? = nil
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined {
            await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        }
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
            try await PHPhotoLibrary.shared().performChanges {
                localIdentifier = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: NBImage.url(id: id))?.placeholderForCreatedAsset?.localIdentifier
            }
        }
        return localIdentifier
            
    }
}
