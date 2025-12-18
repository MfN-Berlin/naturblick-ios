//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

enum Operation: Encodable {
    case create(CreateOperation)
    case patch(PatchOperation)
    case upload(UploadOperation)
    case delete(DeleteOperation)
    case viewfieldbook(ViewFieldbookOperation)
    case viewportrait(ViewPortraitOperation)
    case viewcharacters(ViewCharactersOperation)
    
    enum CodingKeys: String, CodingKey {
        case operation
        case data
    }

    func encode(to encoder: Encoder) throws {
        var wrapper = encoder.container(keyedBy: CodingKeys.self)
        switch(self) {
        case .create(let operation):
            try wrapper.encode("create", forKey: .operation)
            try wrapper.encode(operation, forKey: .data)
        case .patch(let operation):
            try wrapper.encode("patch", forKey: .operation)
            try wrapper.encode(operation, forKey: .data)
        case .upload(let operation):
            try wrapper.encode("upload_media", forKey: .operation)
            try wrapper.encode(operation, forKey: .data)
        case .delete(let operation):
            try wrapper.encode("delete", forKey: .operation)
            try wrapper.encode(operation, forKey: .data)
        case .viewfieldbook(let operation):
            try wrapper.encode("view_fieldbook", forKey: .operation)
            try wrapper.encode(operation, forKey: .data)
        case .viewportrait(let operation):
            try wrapper.encode("view_portrait", forKey: .operation)
            try wrapper.encode(operation, forKey: .data)
        case .viewcharacters(let operation):
            try wrapper.encode("view_characters", forKey: .operation)
            try wrapper.encode(operation, forKey: .data)
        }
    }

    enum D {
        static let table = Table("operation")
        static let rowid = Expression<Int64>("rowid")
        static let optionalRowid = Expression<Int64?>("rowid")
        static func instance(row: Row) throws -> (Int64, Operation) {
            let createId = try row.get(CreateOperation.D.table[Operation.D.optionalRowid])
            let patchId = try row.get(PatchOperation.D.table[Operation.D.optionalRowid])
            let uploadId = try row.get(UploadOperation.D.table[Operation.D.optionalRowid])
            let deleteId = try row.get(DeleteOperation.D.table[Operation.D.optionalRowid])
            let viewPortraitId = try row.get(ViewPortraitOperation.D.table[Operation.D.optionalRowid])
            let viewFieldbookId = try row.get(ViewFieldbookOperation.D.table[Operation.D.optionalRowid])
            let viewCharactersId = try row.get(ViewCharactersOperation.D.table[Operation.D.optionalRowid])
            
            if createId != nil {
                return (try row.get(Operation.D.table[Operation.D.rowid]), .create(try CreateOperation.D.instance(row: row)))
            } else if patchId != nil {
                return (try row.get(Operation.D.table[Operation.D.rowid]), .patch(try PatchOperation.D.instance(row: row)))
            } else if uploadId != nil {
                return (try row.get(Operation.D.table[Operation.D.rowid]), .upload(try UploadOperation.D.instance(row: row)))
            } else if deleteId != nil {
                return (try row.get(Operation.D.table[Operation.D.rowid]), .delete(try DeleteOperation.D.instance(row: row)))
            } else if viewPortraitId != nil {
                return (try row.get(Operation.D.table[Operation.D.rowid]), .viewportrait(try ViewPortraitOperation.D.instance(row: row)))
            } else if viewFieldbookId != nil {
                return (try row.get(Operation.D.table[Operation.D.rowid]), .viewfieldbook(try ViewFieldbookOperation.D.instance(row: row)))
            } else if viewCharactersId != nil {
                return (try row.get(Operation.D.table[Operation.D.rowid]), .viewcharacters(try ViewCharactersOperation.D.instance(row: row)))
            }else {
                Fail.with(message: "Unknown operation")
            }
        }
    }
}
