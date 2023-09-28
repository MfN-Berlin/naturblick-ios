//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct DBObservation: Decodable, Identifiable {
    let occurenceId: UUID
    let obsIdent: String?
    let obsType: ObsType
    let newSpeciesId: Int64?
    let created: ZonedDateTime
    let mediaId: UUID?
    let thumbnailId: UUID?
    let localMediaId: String?
    let coords: Coordinates?
    let individuals: Int64?
    let behavior: Behavior?
    let details: String?
    let segmStart: Int64?
    let segmEnd: Int64?
    
    var id: UUID {
        occurenceId
    }
}

extension DBObservation {
    enum D {
        static let observation = Table("observation")
        static let backendObservation = Table("backend_observation")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let obsIdent = Expression<String?>("obs_ident")
        static let obsType = Expression<String>("obs_type")
        static let created = Expression<Date>("created")
        static let createdTz = Expression<String>("created_tz")
        static let species = Expression<Int64?>("species")
        static let mediaId = Expression<UUID?>("media_id")
        static let thumbnailId = Expression<UUID?>("thumbnail_id")
        static let localMediaId = Expression<String?>("local_media_id")
        static let coordsLatitude = Expression<Double?>("coords_latitude")
        static let coordsLongitude = Expression<Double?>("coords_longitude")
        static let individuals = Expression<Int64?>("individuals")
        static let behavior = Expression<String?>("behavior")
        static let details = Expression<String?>("details")
        static let segmStart = Expression<Int64?>("segm_start")
        static let segmEnd = Expression<Int64?>("segm_end")

        static func setters(observation: DBObservation) -> [Setter] {
            [
                occurenceId <- observation.occurenceId,
                obsType <- observation.obsType.rawValue,
                created <- observation.created.date,
                createdTz <- observation.created.tz.identifier,
                species <- observation.newSpeciesId,
                mediaId <- observation.mediaId,
                thumbnailId <- observation.thumbnailId,
                coordsLatitude <- observation.coords?.latitude,
                coordsLongitude <- observation.coords?.longitude,
                individuals <- observation.individuals,
                behavior <- observation.behavior?.rawValue,
                details <- observation.details,
                segmStart <- observation.segmStart,
                segmEnd <- observation.segmEnd
            ]
        }

        static func instance(row: Row) throws -> DBObservation {
            var coords: Coordinates? = nil
            if let latitude = try row.get(coordsLatitude), let longitude = try row.get(coordsLongitude) {
                coords = Coordinates(latitude: latitude, longitude: longitude)
            }
            var behaviorEnum: Behavior? = nil
            if let behaviorStr = try row.get(behavior) {
                behaviorEnum = Behavior(rawValue: behaviorStr)
            }
            return DBObservation(
                occurenceId: try row.get(occurenceId),
                obsIdent: try row.get(obsIdent),
                obsType: ObsType(rawValue: try row.get(obsType))!, newSpeciesId: try row.get(species),
                created: ZonedDateTime(date: try row.get(created), tz: TimeZone(identifier: try row.get(createdTz))!),
                mediaId: try row.get(mediaId),
                thumbnailId: try row.get(thumbnailId),
                localMediaId: try row.get(localMediaId),
                coords: coords,
                individuals: try row.get(individuals),
                behavior: behaviorEnum,
                details: try row.get(details),
                segmStart: try row.get(segmStart),
                segmEnd: try row.get(segmEnd)
            )
        }

        static func setters(operation: CreateOperation) -> [Setter] {
            var setters: [Setter] = [
                occurenceId <- operation.occurenceId,
                obsType <- operation.obsType.rawValue,
                created <- operation.created.date,
                createdTz <- operation.created.tz.identifier,
                species <- operation.speciesId
            ]
            if let sStart = operation.segmStart {
                setters.append(segmStart <- sStart)
            }
            if let sEnd = operation.segmEnd {
                setters.append(segmEnd <- sEnd)
            }
            return setters
        }
        
        static func setters(operation: DeleteOperation) -> [Setter] {
            [
                occurenceId <- operation.occurenceId
            ]
        }

        static func setters(operation: PatchOperation) -> [Setter] {
            var setters: [Setter] = []
            if let newDetails = operation.details {
                setters.append(details <- newDetails)
            }
            if let newObsType = operation.obsType {
                setters.append(obsType <- newObsType.rawValue)
            }
            if let latitude = operation.coords?.latitude, let longitude = operation.coords?.longitude {
                setters.append(coordsLatitude <- latitude)
                setters.append(coordsLongitude <- longitude)
            }
            if let newIndividuals = operation.individuals {
                setters.append(individuals <- newIndividuals)
            }
            if let newSpecies = operation.newSpeciesId {
                setters.append(species <- newSpecies)
            }
            if let newMedia = operation.mediaId {
                setters.append(mediaId <- newMedia)
            }
            if let newThumbnail = operation.thumbnailId {
                setters.append(thumbnailId <- newThumbnail)
            }
            if let newBehavior = operation.behavior {
                setters.append(behavior <- newBehavior.rawValue)
            }
            return setters
        }
    }

    var settters: [Setter] {
        DBObservation.D.setters(observation: self)
    }
}

extension DBObservation {
    static let sampleData = DBObservation(
        occurenceId: UUID(),
        obsIdent: nil,
        obsType: .manual,
        newSpeciesId: 1,
        created: ZonedDateTime(),
        mediaId: nil,
        thumbnailId: nil,
        localMediaId: nil,
        coords: nil,
        individuals: nil,
        behavior: nil,
        details: "details",
        segmStart: nil,
        segmEnd: nil
    )
}
