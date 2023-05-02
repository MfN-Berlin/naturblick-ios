//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import CoreData
import SQLite

class ObservationPersistenceController {
    static let shared = ObservationPersistenceController()

    let container: NSPersistentContainer

    private var notificationToken: NSObjectProtocol?
    private var lastToken: NSPersistentHistoryToken?
    private var queue: Connection
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "observations")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        // Enable persistent store remote change notifications
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // Enable persistent history tracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true

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
                        details STRING,
                        FOREIGN KEY(rowid) REFERENCES operation(rowid)
                    );
                    PRAGMA user_version = 1;
                    COMMIT TRANSACTION;
"""
                )
            }
        } catch {
            fatalError("Failed to open queue DB")
        }
        
        // Observe Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            Task {
                await self.fetchPersistentHistory()
            }
        }
    }

    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
           preconditionFailure(error.localizedDescription)
        }
    }

    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = newTaskContext()
        taskContext.name = "persistentHistoryContext"
        try await taskContext.perform {
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            guard let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty else {
                return
            }
            self.mergePersistentHistoryChanges(from: history)
            return
        }
    }

    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }

    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }

    func importObservations(from observations: [Observation]) async throws {
        guard !observations.isEmpty else { return }

        let taskContext = newTaskContext()
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importObservations"

        try await taskContext.perform {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "ObservationEntity"))
            try taskContext.execute(deleteRequest)
            let batchInsertRequest = self.newBatchInsertRequest(with: observations)
            let fetchResult = try taskContext.execute(batchInsertRequest)
            if let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            preconditionFailure("Failed to insert")
        }
    }

    private func newBatchInsertRequest(with observations: [Observation]) -> NSBatchInsertRequest {
        var index = 0
        let total = observations.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: ObservationEntity.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: observations[index].dictionaryValue)
            index += 1
            return false
        })
        return batchInsertRequest
    }

    private static let operationTable = Table("operation")

    static let dateFormatter = ISO8601DateFormatter()

    func insert(operation: CreateOperation) throws {
        try self.queue.transaction {
            let id = try self.queue.run(ObservationPersistenceController.operationTable.insert())
            try self.queue.run(
                CreateOperation.D.table.insert(
                    CreateOperation.D.id <- id,
                    CreateOperation.D.occurenceId <- operation.occurenceId,
                    CreateOperation.D.obsType <- operation.obsType.rawValue,
                    CreateOperation.D.created <- ObservationPersistenceController.dateFormatter.string(from: operation.created.date),
                    CreateOperation.D.createdTz <- operation.created.tz.identifier
                )
            )
        }
    }
}

extension ObservationPersistenceController {
    static var preview: ObservationPersistenceController = {
        let result = ObservationPersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
