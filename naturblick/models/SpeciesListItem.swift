//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct SpeciesListItem: Identifiable {
    var id: String {
        "\(speciesId)_\(isFemale ?? false)"
    }
    var url: String? {
        if isFemale ?? false {
            return femaleUrl
        } else {
            return maleUrl
        }
    }
    var name: String? {
        if let isFemale = isFemale, let speciesName = speciesName {
            if isFemale {
                return "\(speciesName) ♀"
            } else {
                return "\(speciesName) ♂"
            }
        } else {
            return speciesName
        }
    }
    let speciesId: Int64
    let sciname: String
    let speciesName: String?
    let maleUrl: String?
    let femaleUrl: String?
    let synonym: String?
    let isFemale: Bool?
    let wikipedia: String?
    let hasPortrait: Bool
    let group: String
    let audioUrl: String?
}

extension SpeciesListItem {
    static let sampleData = SpeciesListItem(
        speciesId: 1,
        sciname: "Lissotriton vulgaris",
        speciesName: "Teichmolch",
        maleUrl: "/uploads/crop_d60f7f6c98b0fcf1aa52e7b0_f0b5f2e568.jpg",
        femaleUrl: nil,
        synonym: nil,
        isFemale: nil,
        wikipedia: "https://de.wikipedia.org/wiki/Teichmolch",
        hasPortrait: true,
        group: Group.groups[0].id,
        audioUrl: nil
    )
    
    static func find(speciesId: Int64) throws -> SpeciesListItem? {
        let speciesDb: Connection = Connection.speciesDB
        let query = Species.Definition.baseQuery.filter(Species.Definition.table[Species.Definition.id] == speciesId)
        
        return try speciesDb.pluck(query)
            .map { row in
                SpeciesListItem(
                    speciesId: row[Species.Definition.table[Species.Definition.id]],
                    sciname: row[Species.Definition.sciname],
                    speciesName: isGerman() ? row[Species.Definition.gername] : row[Species.Definition.engname],
                    maleUrl: row[Species.Definition.maleUrl],
                    femaleUrl: row[Species.Definition.femaleUrl],
                    synonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engsynonym],
                    isFemale: nil,
                    wikipedia: row[Species.Definition.wikipedia],
                    hasPortrait: row[Species.Definition.optionalPortraitId] != nil,
                    group: row[Species.Definition.group],
                    audioUrl: row[Portrait.Definition.audioUrl]
                )
            }
    }
}

extension Species {
    var listItem: SpeciesListItem {
        SpeciesListItem(
            speciesId: id,
            sciname: sciname,
            speciesName: speciesName,
            maleUrl: maleUrl,
            femaleUrl: femaleUrl,
            synonym: synonym,
            isFemale: nil,
            wikipedia: wikipedia,
            hasPortrait: hasPortrait,
            group: group,
            audioUrl: nil
        )
    }
}
