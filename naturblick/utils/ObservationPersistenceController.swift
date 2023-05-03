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
                        created STRING NOT NULL,
                        created_tz STRING NOT NULL,
                        obs_type STRING NOT NULL,
                        details STRING NOT NULL,
                        FOREIGN KEY(rowid) REFERENCES operation(rowid)
                    );
                    CREATE TABLE observation (
                        occurence_id TEXT UNIQUE NOT NULL,
                        created STRING NOT NULL,
                        created_tz STRING NOT NULL,
                        obs_ident STRING,
                        obs_type STRING NOT NULL,
                        species INTEGER,
                        media_id TEXT,
                        thumbnail_id TEXT,
                        local_media_id STRING,
                        coords_latitude DOUBLE,
                        coords_longitude DOUBLE,
                        individuals INTEGER,
                        behavior STRING,
                        details STRING
                    );
                    CREATE TABLE backend_observation (
                        occurence_id TEXT UNIQUE NOT NULL,
                        created STRING NOT NULL,
                        created_tz STRING NOT NULL,
                        obs_ident STRING,
                        obs_type STRING NOT NULL,
                        species INTEGER,
                        media_id TEXT,
                        thumbnail_id TEXT,
                        local_media_id STRING,
                        coords_latitude DOUBLE,
                        coords_longitude DOUBLE,
                        individuals INTEGER,
                        behavior STRING,
                        details STRING
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
        for createOperation in try queue.prepareRowIterator(CreateOperation.D.table.select(*)).map(CreateOperation.D.instance) {
            try queue.run(Observation.D.observation.insert(or: .replace, Observation.D.setters(operation: createOperation)))
        }
    }

    func updateAndRefresh() throws {
        try update()
        try refresh()
    }

    func importObservations(from observations: [Observation]) throws {
        let observationSetters = observations.map({ observation in
            observation.settters
        })
        try queue.transaction {
            try queue.run(Observation.D.backendObservation.delete())
            try queue.run(Observation.D.backendObservation.insertMany(observationSetters))
            try updateAndRefresh()
        }
    }

    private static let operationTable = Table("operation")

    func insert(operation: CreateOperation) throws {
        try queue.transaction {
            let id = try queue.run(ObservationPersistenceController.operationTable.insert())
            try queue.run(
                CreateOperation.D.table.insert(operation.setters(id: id))
            )
            try updateAndRefresh()
        }
    }
}

extension ObservationPersistenceController {
    static var preview: ObservationPersistenceController = {
        ObservationPersistenceController(inMemory: true)
    }()
}
