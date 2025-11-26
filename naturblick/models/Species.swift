//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

struct Species: Identifiable, Equatable {
    let id: Int64
    let group: Group
    let sciname: String
    let gername: String?
    let engname: String?
    let wikipedia: String?
    let maleUrl: String?
    let maleUrlOrig: String?
    let femaleUrl: String?
    let gersynonym: String?
    let engsynonym: String?
    let redListGermany: String?
    let iucnCategory: String?
    let hasPortrait: Bool
    let gersearchfield: String?
    let engsearchfield: String?
    
    var speciesName: String? {
        isGerman() ? gername : engname
    }
    
    var synonym: String? {
        isGerman() ? gersynonym : engsynonym
    }
}

extension Species {
    struct Definition {
        static let table = Table("species")
        static let tableAlias = table.alias("species2")

        static let id = Expression<Int64>("rowid")
        static let acceptedId = Expression<Int64?>("rowid")
        static let group = Expression<String>("group_id")
        static let sciname = Expression<String>("sciname")
        static let gername = Expression<String?>("gername")
        static let engname = Expression<String?>("engname")
        static let wikipedia = Expression<String?>("wikipedia")
        static let maleUrl = Expression<String?>("image_url")
        static let maleUrlOrig = Expression<String?>("image_url_orig")
        static let femaleUrl = Expression<String?>("female_image_url")
        static let gersynonym = Expression<String?>("gersynonym")
        static let engsynonym = Expression<String?>("engsynonym")
        static let redListGermany = Expression<String?>("red_list_germany")
        static let iucnCategory = Expression<String?>("iucn_category")
        static let isFemale = Expression<Bool?>("female")
        static let hasPortrait = Expression<Bool>("has_portrait")
        static let optionalPortraitId = Portrait.Definition.table[Expression<Int64?>("rowid")]
        static let optionalLanguage = Portrait.Definition.table[Expression<Int64?>("language")]
        static let accepted = Expression<Int64?>("accepted")
        static let gersearchfield = Expression<String?>("gersearchfield")
        static let engsearchfield = Expression<String?>("engsearchfield")
        static let baseQuery = table
            .select(table[*], optionalPortraitId, Portrait.Definition.audioUrl, Group.Definition.table[Group.Definition.name], Group.Definition.table[Group.Definition.nature])
            .join(.leftOuter, Portrait.Definition.table, on: table[id] == Portrait.Definition.speciesId)
            .join(.inner, Group.Definition.table, on: table[group] == Group.Definition.table[Group.Definition.name])
            .filter(optionalLanguage == getLanguageId() || optionalLanguage == nil)
    }
    
    private static func searchOrNil(search: String) -> String? {
        return search.isEmpty ? nil : "%\(search)%"
    }

    static func acceptedSpeciesId(row: Row) -> Int64 {
        return row[Species.Definition.tableAlias[Species.Definition.acceptedId]] ?? row[Species.Definition.table[Species.Definition.id]]
    }

    private static func fromRow(row: Row, hasPortraits: Bool, alias: SchemaType) -> Species {
        return Species(
            id: row[alias[Species.Definition.id]],
            group: Group.fromRow(row: row),
            sciname: row[alias[Species.Definition.sciname]],
            gername: row[alias[Species.Definition.gername]],
            engname: row[alias[Species.Definition.engname]],
            wikipedia: row[alias[Species.Definition.wikipedia]],
            maleUrl: row[alias[Species.Definition.maleUrl]],
            maleUrlOrig: row[alias[Species.Definition.maleUrlOrig]],
            femaleUrl: row[alias[Species.Definition.femaleUrl]],
            gersynonym: row[alias[Species.Definition.gersynonym]],
            engsynonym: row[alias[Species.Definition.engsynonym]],
            redListGermany: row[alias[Species.Definition.redListGermany]],
            iucnCategory: row[alias[Species.Definition.iucnCategory]],
            hasPortrait: hasPortraits,
            gersearchfield: row[alias[Species.Definition.gersearchfield]],
            engsearchfield: row[alias[Species.Definition.engsearchfield]]
        )
    }

    static func acceptedFromRow(row: Row, hasPortraits: Bool) -> Species {
        return if row[Species.Definition.tableAlias[Species.Definition.acceptedId]] != nil {
            Species.fromRow(row: row, hasPortraits: hasPortraits, alias: Species.Definition.tableAlias)
        } else {
            Species.fromRow(row: row, hasPortraits: hasPortraits, alias: Species.Definition.table)
        }
    }

   static func query(searchString: String) -> QueryType {
       let searchString = searchOrNil(search: searchString)
       let query = Definition.baseQuery
       let queryWithSearch = searchString != nil ? (isGerman() ? query.filter(Species.Definition.gersearchfield.like(searchString!)) : query.filter(Species.Definition.engsearchfield.like(searchString!)) ) : query
       return queryWithSearch
           .filter(Species.Definition.gersearchfield != nil)
           .order(isGerman() ?
                  [Expression(literal: "species.gername is null"), Expression(literal: "species.gername"), Expression(literal: "species.gersynonym is null"), Expression(literal: "species.gersynonym"), Species.Definition.sciname] :
                    [Expression(literal: "species.engname is null"), Expression(literal: "species.engname"), Expression(literal: "species.engsynonym is null"), Expression(literal: "species.engsynonym"), Species.Definition.sciname])
   }
    
    func matches(searchText: String) -> Bool {
        if(isGerman()) {
            return gername?.lowercased().contains(searchText) ?? false
            || gersynonym?.lowercased().contains(searchText) ?? false
            || sciname.lowercased().contains(searchText)
        } else {
            return engname?.lowercased().contains(searchText) ?? false
            || engsynonym?.lowercased().contains(searchText) ?? false
            || sciname.lowercased().contains(searchText)
        }
    }
}

extension Species {
    static let sampleData = Species(
        id: 44,
        group: Group.exampleData,
        sciname: "Sturnus vulgaris",
        gername: "Star",
        engname: "Starling",
        wikipedia: "https://de.wikipedia.org/wiki/Star_(Art)",
        maleUrl: "/uploads/crop_053557dc868d4fac054473e2_f1d6e2d875.jpg",
        maleUrlOrig: "/uploads/crop_053557dc868d4fac054473e2_f1d6e2d875.jpg",
        femaleUrl: nil,
        gersynonym: nil,
        engsynonym: nil,
        redListGermany: "gefahrdet",
        iucnCategory: "LC",
        hasPortrait: true,
        gersearchfield: nil,
        engsearchfield: nil
    )
}
