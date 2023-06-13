//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import CoreData
import SQLite

class ObservationPersistenceController: ObservableObject {
    private var queue: Connection
    @Published var observations: [Observation] = []
    init(inMemory: Bool = false) {
     
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        do {
            if inMemory {
                self.queue = try Connection(.inMemory)
            } else {
                self.queue = try Connection("\(path)/queue.sqlite3")
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

    func insert(data: CreateData) throws {
        try queue.transaction {
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
