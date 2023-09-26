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
                        species_id INTEGER,
                        behavior TEXT,
                        segm_start REAL,
                        segm_end REAL,
                        FOREIGN KEY(rowid) REFERENCES operation(rowid) ON DELETE CASCADE
                    );
                    CREATE TABLE upload_operation (
                        rowid INTEGER PRIMARY KEY NOT NULL,
                        occurence_id TEXT NOT NULL,
                        media_id TEXT NOT NULL,
                        mime TEXT NOT NULL
                    );
                    CREATE TABLE delete_operation (
                        rowid INTEGER PRIMARY KEY NOT NULL,
                        occurence_id TEXT NOT NULL,
                        FOREIGN KEY(rowid) REFERENCES operation(rowid) ON DELETE CASCADE
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
                        details TEXT,
                        segm_start INTEGER,
                        segm_end INTEGER
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
                        details TEXT,
                        segm_start INTEGER,
                        segm_end INTEGER
                    );
                    CREATE TABLE sync (
                        sync_id INTEGER PRIMARY KEY NOT NULL
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
        let obs = try queue.prepareRowIterator(
            DBObservation.D.observation.select(*).order(DBObservation.D.created.desc)
        ).map(DBObservation.D.instance)
        let speciesDb = Connection.speciesDB
        observations = try obs.map { observation in
            guard let speciesId = observation.newSpeciesId else {
                return Observation(observation: observation, species: nil)
            }
            guard let row = try speciesDb.pluck(Species.Definition.table.filter(Species.Definition.id == speciesId)) else {
                return Observation(observation: observation, species: nil)
            }
            let species = Species(
                id: row[Species.Definition.id],
                group: row[Species.Definition.group],
                sciname: row[Species.Definition.sciname],
                gername: row[Species.Definition.gername],
                engname: row[Species.Definition.engname],
                wikipedia: row[Species.Definition.wikipedia],
                maleUrl: row[Species.Definition.maleUrl],
                femaleUrl: row[Species.Definition.femaleUrl],
                gersynonym: row[Species.Definition.gersynonym],
                engsynonym: row[Species.Definition.engsynonym],
                redListGermany: row[Species.Definition.redListGermany],
                iucnCategory: row[Species.Definition.iucnCategory],
                hasPortrait: false
            )
            return Observation(observation: observation, species: species)
        }
    }
    
    func getSync() throws -> Sync? {
        try queue.prepare(Sync.D.sync.select(*)).map(Sync.D.instance).first
    }
    
    private func setSyncId(syncId: Int64?) throws {
        try queue.run(Sync.D.sync.delete())
        guard let syncId = syncId else {
            return
        }
        try queue.run(Sync.D.sync.insert(Sync(syncId: syncId).settters))
    }
    
    func update() throws {
        try queue.run(DBObservation.D.observation.delete())
        try queue.run(DBObservation.D.observation.insert(DBObservation.D.backendObservation.select(*)))
        for operation in try getPendingOperations().1 {
            switch(operation) {
            case .create(let create):
                try queue.run(DBObservation.D.observation.insert(or: .replace, DBObservation.D.setters(operation: create)))
            case .patch(let patch):
                try queue.run(DBObservation.D.observation.filter(DBObservation.D.occurenceId == patch.occurenceId).update(DBObservation.D.setters(operation: patch)))
            case .upload:
                do {} // No need to change observation due to uploading media
            case .delete(let delete):
                try queue.run(DBObservation.D.observation.filter(DBObservation.D.occurenceId == delete.occurenceId).delete())
            }
        }
    }

    func updateAndRefresh() throws {
        try update()
        try refresh()
    }

    private func importObservations(from observations: [DBObservation]) throws {
        guard !observations.isEmpty else {
            return
        }
        let observationSetters = observations.map({ observation in
            observation.settters
        })
        
        try queue.run(DBObservation.D.backendObservation.insertMany(observationSetters))
        try updateAndRefresh()
    }
    
    func truncateObservations() throws {
        try queue.run(DBObservation.D.backendObservation.delete())
    }
    
    func handleChunk(from observations: [DBObservation], ids: [Int64], syncId: Int64?) throws {
        try queue.transaction {
            try importObservations(from: observations)
            try clearPendingOperations(ids: ids)
            try setSyncId(syncId: syncId)
        }
    }

    private func insert(occurenceId: UUID, image: NBImage) throws {
        let uiImage = image.image
        let upload = UploadOperation(occurenceId: occurenceId, mediaId: image.id, mime: .jpeg)
        let size = uiImage.size
        var resultImage = uiImage
        if size.width > .maxResolution || size.height > .maxResolution {
            let widthRatio  = .maxResolution / size.width
            let heightRatio = .maxResolution / size.height
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            uiImage.draw(in: CGRect(origin: .zero, size: newSize))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        let data = resultImage.jpegData(compressionQuality: .jpegQuality)
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
    
    func delete(occurenceId: UUID) throws {
        let delete = DeleteOperation(occurenceId: occurenceId)
        let deleteId = try queue.run(Operation.D.table.insert())
        try queue.run(DeleteOperation.D.table.insert(delete.setters(id: deleteId)))
        try updateAndRefresh()
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
            if let thumbnail = data.thumbnail {
                try insert(occurenceId: data.original.occurenceId, image: thumbnail)
            }
            
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
                .join(
                    .leftOuter,
                    DeleteOperation.D.table,
                    on: Operation.D.table[Operation.D.rowid] == DeleteOperation.D.table[DeleteOperation.D.rowid]
                )
                .select(*)
                .order(Operation.D.rowid.asc))
        .map(Operation.D.instance)
        return (operationAndId.map { $0.0 }, operationAndId.map { $0.1 })
    }

    private func clearPendingOperations(ids: [Int64]) throws {
        try queue.run(Operation.D.table.filter(ids.contains(Operation.D.rowid)).delete())
    }
}

extension ObservationPersistenceController {
    static var preview: ObservationPersistenceController = {
        ObservationPersistenceController(inMemory: true)
    }()
}
