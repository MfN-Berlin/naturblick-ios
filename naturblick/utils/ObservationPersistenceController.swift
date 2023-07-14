//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import CoreData
import SQLite
import UIKit

class ObservationPersistenceController: ObservableObject {
    private var queue: Connection
    @Published var observations: [Observation] = []
    init(inMemory: Bool = false) {
        let fileURL = URL.supportDir.appendingPathComponent("queue.sqlite3")
        
        do {
            if inMemory {
                self.queue = try Connection(.inMemory)
            } else {
                self.queue = try Connection(fileURL.absoluteString)
            }
            try self.queue.execute("PRAGMA foreign_keys = ON;")
            if self.queue.userVersion == 0 {
                try self.queue.execute(
"""
                    BEGIN TRANSACTION;
                    CREATE TABLE operation (
                        rowid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
                    );
                    CREATE TABLE create_operation (
                        rowid INTEGER PRIMARY KEY NOT NULL,
                        occurence_id TEXT UNIQUE NOT NULL,
                        created TEXT NOT NULL,
                        created_tz TEXT NOT NULL,
                        obs_type TEXT NOT NULL,
                        cc_by_name TEXT NOT NULL,
                        app_version TEXT NOT NULL,
                        device_identifier TEXT NOT NULL,
                        species_id INTEGER,
                        FOREIGN KEY(rowid) REFERENCES operation(rowid) ON DELETE CASCADE
                    );
                    CREATE TABLE patch_operation (
                        rowid INTEGER PRIMARY KEY NOT NULL,
                        occurence_id TEXT NOT NULL,
                        obs_type TEXT,
                        details TEXT,
                        coords_latitude DOUBLE,
                        coords_longitude DOUBLE,
                        individuals INTEGER,
                        media_id TEXT,
                        thumbnail_id TEXT,
                        FOREIGN KEY(rowid) REFERENCES operation(rowid) ON DELETE CASCADE
                    );
                    CREATE TABLE upload_operation (
                        rowid INTEGER PRIMARY KEY NOT NULL,
                        occurence_id TEXT NOT NULL,
                        media_id TEXT NOT NULL,
                        mime TEXT NOT NULL
                    );
                    CREATE TABLE observation (
                        occurence_id TEXT UNIQUE NOT NULL,
                        created TEXT NOT NULL,
                        created_tz TEXT NOT NULL,
                        obs_ident TEXT,
                        obs_type TEXT NOT NULL,
                        species INTEGER,
                        media_id TEXT,
                        thumbnail_id TEXT,
                        local_media_id TEXT,
                        coords_latitude DOUBLE,
                        coords_longitude DOUBLE,
                        individuals INTEGER,
                        behavior TEXT,
                        details TEXT
                    );
                    CREATE TABLE backend_observation (
                        occurence_id TEXT UNIQUE NOT NULL,
                        created TEXT NOT NULL,
                        created_tz TEXT NOT NULL,
                        obs_ident TEXT,
                        obs_type TEXT NOT NULL,
                        species INTEGER,
                        media_id TEXT,
                        thumbnail_id TEXT,
                        local_media_id TEXT,
                        coords_latitude DOUBLE,
                        coords_longitude DOUBLE,
                        individuals INTEGER,
                        behavior TEXT,
                        details TEXT
                    );
                    PRAGMA user_version = 1;
                    COMMIT TRANSACTION;
"""
                )
            }
            try refresh()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func refresh() throws {
        observations = try queue.prepareRowIterator(
            Observation.D.observation.select(*).order(Observation.D.created.desc)
        ).map(Observation.D.instance)
    }
    
    func update() throws {
        try queue.run(Observation.D.observation.delete())
        try queue.run(Observation.D.observation.insert(Observation.D.backendObservation.select(*)))
        for operation in try getPendingOperations().1 {
            switch(operation) {
            case .create(let create):
                try queue.run(Observation.D.observation.insert(or: .replace, Observation.D.setters(operation: create)))
            case .patch(let patch):
                try queue.run(Observation.D.observation.filter(Observation.D.occurenceId == patch.occurenceId).update(Observation.D.setters(operation: patch)))
            case .upload:
                do {} // No need to change observation due to uploading media
            }
        }
    }

    func updateAndRefresh() throws {
        try update()
        try refresh()
    }

    func importObservations(from observations: [Observation]) throws {
        guard !observations.isEmpty else {
            return
        }
        let observationSetters = observations.map({ observation in
            observation.settters
        })
        try queue.transaction {
            try queue.run(Observation.D.backendObservation.delete())
            try queue.run(Observation.D.backendObservation.insertMany(observationSetters))
            try updateAndRefresh()
        }
    }

    private func insert(occurenceId: UUID, image: NBImage) throws {
        let upload = UploadOperation(occurenceId: occurenceId, mediaId: image.id, mime: .jpeg)
        let size = image.image.size
        let widthRatio  = .maxResolution / size.width
        let heightRatio = .maxResolution / size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.image.draw(in: CGRect(origin: .zero, size: newSize))
        let data = UIGraphicsGetImageFromCurrentImageContext()?.jpegData(compressionQuality: .jpegQuality)
        UIGraphicsEndImageContext()

        try data!.write(to: URL.uploadFileURL(id: image.id, mime: upload.mime))
        let uploadId = try queue.run(Operation.D.table.insert())
        try queue.run(UploadOperation.D.table.insert(upload.setters(id: uploadId)))
    }
    
    private func insert(occurenceId: UUID, sound: NBSound) throws {
        try FileManager.default.copyItem(at: sound.url, to: URL.uploadFileURL(id: sound.id, mime: .mp4))
        let upload = UploadOperation(occurenceId: occurenceId, mediaId: sound.id, mime: .mp4)
        let uploadId = try queue.run(Operation.D.table.insert())
        try queue.run(UploadOperation.D.table.insert(upload.setters(id: uploadId)))
    }
    
    func insert(data: CreateData) throws {
        try queue.transaction {
            if let media = data.image.image {
                try insert(occurenceId: data.occurenceId, image: media)
                if let thumbnail = data.image.crop {
                    try insert(occurenceId: data.occurenceId, image: thumbnail)
                }
            }
            if let media = data.sound.sound {
                try insert(occurenceId: data.occurenceId, sound: media)
                if let thumbnail = data.sound.crop {
                    try insert(occurenceId: data.occurenceId, image: thumbnail)
                }
            }
            let createId = try queue.run(Operation.D.table.insert())
            try queue.run(
                CreateOperation.D.table.insert(data.create.setters(id: createId))
            )
            if let patch = data.patch {
                let patchId = try queue.run(Operation.D.table.insert())
                try queue.run(
                    PatchOperation.D.table.insert(patch.setters(id: patchId))
                )
            }
            try updateAndRefresh()
        }
    }

    func insert(data: EditData) throws {
        try queue.transaction {
            if let patch = data.patch {
                let patchId = try queue.run(Operation.D.table.insert())
                try queue.run(
                    PatchOperation.D.table.insert(patch.setters(id: patchId))
                )
                try updateAndRefresh()
            }
        }
    }

    func getPendingOperations() throws -> ([Int64], [Operation]) {
        let operationAndId = try queue.prepareRowIterator(
            Operation.D.table
                .join(
                    .leftOuter,
                    CreateOperation.D.table,
                    on: Operation.D.table[Operation.D.rowid] == CreateOperation.D.table[CreateOperation.D.rowid]
                )
                .join(
                    .leftOuter,
                    PatchOperation.D.table,
                    on: Operation.D.table[Operation.D.rowid] == PatchOperation.D.table[PatchOperation.D.rowid]
                )
                .join(
                    .leftOuter,
                    UploadOperation.D.table,
                    on: Operation.D.table[Operation.D.rowid] == UploadOperation.D.table[UploadOperation.D.rowid]
                )
                .select(*)
                .order(Operation.D.rowid.asc))
        .map(Operation.D.instance)
        return (operationAndId.map { $0.0 }, operationAndId.map { $0.1 })
    }

    func clearPendingOperations(ids: [Int64]) throws {
        try queue.run(Operation.D.table.filter(ids.contains(Operation.D.rowid)).delete())
    }
}

extension ObservationPersistenceController {
    static var preview: ObservationPersistenceController = {
        ObservationPersistenceController(inMemory: true)
    }()
}
