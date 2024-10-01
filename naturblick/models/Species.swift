//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

struct Species: Identifiable, Equatable {
    let id: Int64
    let group: String
    let sciname: String
    let gername: String?
    let engname: String?
    let wikipedia: String?
    let maleUrl: String?
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
        
        static let id = Expression<Int64>("rowid")
        static let acceptedId = Expression<Int64?>("rowid")
        static let group = Expression<String>("group_id")
        static let sciname = Expression<String>("sciname")
        static let gername = Expression<String?>("gername")
        static let engname = Expression<String?>("engname")
        static let wikipedia = Expression<String?>("wikipedia")
        static let maleUrl = Expression<String?>("image_url")
        static let femaleUrl = Expression<String?>("female_image_url")
        static let gersynonym = Expression<String?>("gersynonym")
        static let engsynonym = Expression<String?>("engsynonym")
        static let redListGermany = Expression<String?>("red_list_germany")
        static let iucnCategory = Expression<String?>("iucn_category")
        static let isFemale = Expression<Bool?>("female")
        static let hasPortrait = Expression<Bool>("has_portrait")
        static let optionalPortraitId = Portrait.Definition.table[Expression<Int64?>("rowid")]
        static let optionalLanguage = Portrait.Definition.table[Expression<Int64?>("language")]
        static let gersearchfield = Expression<String?>("gersearchfield")
        static let engsearchfield = Expression<String?>("engsearchfield")
        static let baseQuery = table
            .select(table[*], optionalPortraitId, Portrait.Definition.audioUrl)
            .join(.leftOuter, Portrait.Definition.table, on: table[id] == Portrait.Definition.speciesId)
            .filter(optionalLanguage == getLanguageId() || optionalLanguage == nil)
    }
    
    private static func searchOrNil(search: String) -> String? {
        return search.isEmpty ? nil : "%\(search)%"
    }

   static func query(searchString: String) -> QueryType {
       let searchString = searchOrNil(search: searchString)
       let query = Definition.baseQuery
       let queryWithSearch = searchString != nil ? (isGerman() ? query.filter(Species.Definition.gersearchfield.like(searchString!)) : query.filter(Species.Definition.engsearchfield.like(searchString!)) ) : query
       return queryWithSearch
           .filter(Species.Definition.gersearchfield != nil)
           .order(isGerman() ?
                  [Expression(literal: "gername is null"), Expression(literal: "gername"), Expression(literal: "gersynonym is null"), Expression(literal: "gersynonym"), Species.Definition.sciname] :
                    [Expression(literal: "engname is null"), Expression(literal: "engname"), Expression(literal: "engsynonym is null"), Expression(literal: "engsynonym"), Species.Definition.sciname])
   }
}

extension Species {
    static let sampleData = Species(
        id: 44,
        group: "bird",
        sciname: "Sturnus vulgaris",
        gername: "Star",
        engname: "Starling",
        wikipedia: "https://de.wikipedia.org/wiki/Star_(Art)",
        maleUrl: "/uploads/crop_053557dc868d4fac054473e2_f1d6e2d875.jpg",
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
