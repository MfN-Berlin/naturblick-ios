//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct UploadOperation: Encodable {
    let occurenceId: UUID
    let mediaId: UUID
    let mime: MimeType
    
    private enum CodingKeys: String, CodingKey {
        case occurenceId, mediaId
    }
}

extension UploadOperation {
    enum D {
        static let table = Table("upload_operation")
        static let rowid = Expression<Int64>("rowid")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let mediaId = Expression<UUID>("media_id")
        static let mime = Expression<String>("mime")

        static func setters(id: Int64, operation: UploadOperation) -> [Setter] {
            [
                rowid <- id,
                occurenceId <- operation.occurenceId,
                mediaId <- operation.mediaId,
                mime <- operation.mime.rawValue
            ]
        }

        static func instance(row: Row) throws -> UploadOperation {
            return UploadOperation(
                occurenceId: try row.get(table[occurenceId]),
                mediaId: try row.get(table[mediaId]),
                mime: MimeType(rawValue: try row.get(table[mime]))!
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        UploadOperation.D.setters(id: id, operation: self)
    }
}
