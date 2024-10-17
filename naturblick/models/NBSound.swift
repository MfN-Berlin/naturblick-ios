//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import os

struct SoundFromTo {
    let from: Int64
    let to: Int64
}

extension SoundFromTo {
    static func createSoundFromTo(observation: DBObservation) -> SoundFromTo? {
        if let segmStart = observation.segmStart, let segmEnd = observation.segmEnd {
            return SoundFromTo(from: segmStart, to: segmEnd)
        } else {
            return nil
        }
    }
}

struct NBSound {
    let id: UUID
    var soundFromTo: SoundFromTo? = nil
    
    init() {
        self.id = UUID()
    }
    
    init(id: UUID, backend: Backend, obsIdent: String?, soundFromTo: SoundFromTo?) async throws {
        self.id = id
        self.soundFromTo = soundFromTo
        let url = NBSound.url(id: id)
        let path = url.path
        if !FileManager.default.fileExists(atPath: path) {
            if let obsIdent = obsIdent, let oldPath = NBSound.findOld(obsIdent: obsIdent) {
                do {
                    Logger.compat.info("Copy \(oldPath, privacy: .public) to \(path, privacy: .public)")
                    try FileManager.default.copyItem(atPath: oldPath, toPath: path)
                    Logger.compat.info("Deleting \(oldPath, privacy: .public)")
                    try? FileManager.default.removeItem(atPath: oldPath)
                    Logger.compat.info("Successfully moved local sound \(id, privacy: .public) from \(oldPath, privacy: .public)")
                } catch {
                    Logger.compat.info("Failed to create sound from \(oldPath, privacy: .public): \(error)")
                    let data = try await backend.downloadSound(mediaId: id)
                    FileManager.default.createFile(atPath: path, contents: data)
                }
            } else {
                let data = try await backend.downloadSound(mediaId: id)
                FileManager.default.createFile(atPath: path, contents: data)
            }
        }
    }

    var url: URL {
        return NBSound.url(id: id)
    }

    static func url(id: UUID) -> URL {
        return URL.documentsDirectory.appendingPathComponent(id.filename(mime: .mp4))
    }

    static func oldUrl(obsIdent: String) -> URL? {
        URL.oldRecordings?.appendingPathComponent("\(obsIdent).mp4", isDirectory: false)
    }

    private static func findOld(obsIdent: String) -> String? {
        guard let path = oldUrl(obsIdent: obsIdent)?.path else {
            Logger.compat.warning("No path for \(obsIdent, privacy: .public)")
            return nil
        }

        guard FileManager.default.fileExists(atPath: path) else {
            Logger.compat.warning("No file found at \(path, privacy: .public)")
            return nil
        }
        return path
    }

    static func loadOld(occurenceId: UUID, obsIdent: String, persistenceController: ObservationPersistenceController, soundFromTo: SoundFromTo?) -> NBSound? {
        Logger.compat.info("Trying to find audio for \(occurenceId, privacy: .public) \(obsIdent, privacy: .public)")
        var newSound = NBSound()
        newSound.soundFromTo = soundFromTo
        
        guard let path = NBSound.findOld(obsIdent: obsIdent) else {
            Logger.compat.warning("Could not find audio for \(occurenceId, privacy: .public)")
            return nil
        }

        do {
            Logger.compat.info("Copy \(path, privacy: .public) to \(newSound.url.path, privacy: .public), \(occurenceId, privacy: .public)")
            try FileManager.default.copyItem(atPath: path, toPath: newSound.url.path)
            Logger.compat.info("Create upload operation for \(newSound.url.path, privacy: .public), \(occurenceId, privacy: .public)")
            try persistenceController.addMissingSound(occurenceId: occurenceId, sound: newSound)
            Logger.compat.info("Deleting \(path, privacy: .public), \(occurenceId, privacy: .public)")
            try? FileManager.default.removeItem(atPath: path)
            Logger.compat.info("Successfully created sound \(newSound.id, privacy: .public) from \(path, privacy: .public), \(occurenceId, privacy: .public)")
            return newSound
        } catch {
            Logger.compat.warning("Failed to create sound for \(path, privacy: .public), \(occurenceId, privacy: .public): \(error)")
            return nil
        }
    }
}
