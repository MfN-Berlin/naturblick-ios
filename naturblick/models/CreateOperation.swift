//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

struct CreateOperation {
    var occurenceId: UUID = UUID()
    var obsType: ObsType = .manual
    var created: ZonedDateTime = ZonedDateTime()
    var details: String = ""
    var ccByName: String = "MfN Naturblick"
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    var deviceIdentifier: String = Configuration.deviceIdentifier
}

extension CreateOperation: Encodable {
    enum CodingKeys: String, CodingKey {
        case occurenceId
        case obsType
        case created
        case details
        case ccByName
        case appVersion
        case deviceIdentifier
    }
    enum WrapperCodingKeys: String, CodingKey {
        case operation
        case data
    }
    func encode(to encoder: Encoder) throws {
        var wrapper = encoder.container(keyedBy: WrapperCodingKeys.self)
        try wrapper.encode("create", forKey: .operation)
        var container = wrapper.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(occurenceId, forKey: .occurenceId)
        try container.encode(obsType, forKey: .obsType)
        try container.encode(created, forKey: .created)
        try container.encode(details, forKey: .details)
        try container.encode(ccByName, forKey: .ccByName)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(deviceIdentifier, forKey: .deviceIdentifier)
    }
}

extension CreateOperation {
    enum D {
        static let table = Table("create_operation")
        static let rowid = Expression<Int64>("rowid")
        static let occurenceId = Expression<UUID>("occurence_id")
        static let obsType = Expression<String>("obs_type")
        static let created = Expression<Date>("created")
        static let createdTz = Expression<String>("created_tz")
        static let details = Expression<String>("details")
        static let ccByName = Expression<String>("cc_by_name")
        static let appVersion = Expression<String>("app_version")
        static let deviceIdentifier = Expression<String>("device_identifier")

        static func setters(id: Int64, operation: CreateOperation) -> [Setter] {
            [
                rowid <- id,
                occurenceId <- operation.occurenceId,
                obsType <- operation.obsType.rawValue,
                created <- operation.created.date,
                createdTz <- operation.created.tz.identifier,
                details <- operation.details,
                ccByName <- operation.ccByName,
                appVersion <- operation.appVersion,
                deviceIdentifier <- operation.deviceIdentifier
            ]
        }

        static func instance(row: Row) throws -> CreateOperation {
            return CreateOperation(
                occurenceId: try row.get(occurenceId),
                obsType: ObsType(rawValue: try row.get(obsType))!,
                created: ZonedDateTime(date: try row.get(created), tz: TimeZone(identifier: try row.get(createdTz))!),
                details: try row.get(details),
                ccByName: try row.get(ccByName),
                appVersion: try row.get(appVersion),
                deviceIdentifier: try row.get(deviceIdentifier)
            )
        }
    }

    func setters(id: Int64) -> [Setter] {
        CreateOperation.D.setters(id: id, operation: self)
    }
}
