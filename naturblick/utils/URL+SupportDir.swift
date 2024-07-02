//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

extension URL {
    static let supportDir = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static func uploadFileURL(id: UUID, mime: MimeType) -> URL {
        return supportDir.appendingPathComponent(id.filename(mime: mime))
    }

    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static func fileURL(id: UUID, mime: MimeType) -> URL {
        return documentsDirectory.appendingPathComponent(id.filename(mime: mime))
    }
    func fileSizeBytes() -> Int {
        do {
            let resources = try self.resourceValues(forKeys:[.fileSizeKey])
            return resources.fileSize!
        } catch {
            Fail.with(error)
        }
    }
    
    static let oldDir: URL? = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("NoCloud", isDirectory: true)
    static let oldRecordings: URL? = oldDir?.appendingPathComponent("Recordings", isDirectory: true)
    static let oldObservationsFile: URL? = oldDir?.appendingPathComponent("userObsList.json", isDirectory: false)
    static let syncOperationsFile: URL? = oldDir?.appendingPathComponent("syncOperations.json", isDirectory: false)
}
