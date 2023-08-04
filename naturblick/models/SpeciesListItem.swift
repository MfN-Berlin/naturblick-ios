//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

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
        if let isFemale = isFemale, let gername = gername {
            if isFemale {
                return "\(gername) ♀"
            } else {
                return "\(gername) ♂"
            }
        } else {
            return gername
        }
    }
    let speciesId: Int64
    let sciname: String
    let gername: String?
    let maleUrl: String?
    let femaleUrl: String?
    let gersynonym: String?
    let isFemale: Bool?
    let wikipedia: String?
    let hasPortrait: Bool
    let group: String
}

extension SpeciesListItem {
    static let sampleData = SpeciesListItem(
        speciesId: 1,
        sciname: "Lissotriton vulgaris",
        gername: "Teichmolch",
        maleUrl: "/uploads/crop_d60f7f6c98b0fcf1aa52e7b0_f0b5f2e568.jpg",
        femaleUrl: nil,
        gersynonym: nil,
        isFemale: nil,
        wikipedia: "https://de.wikipedia.org/wiki/Teichmolch",
        hasPortrait: true,
        group: Group.groups[0].id
    )
}

extension Species {
    var listItem: SpeciesListItem {
        SpeciesListItem(
            speciesId: id,
            sciname: sciname,
            gername: gername,
            maleUrl: maleUrl,
            femaleUrl: femaleUrl,
            gersynonym: gersynonym,
            isFemale: nil,
            wikipedia: wikipedia,
            hasPortrait: hasPortrait,
            group: group
        )
    }
}
