//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

class SourcesImprintViewModel: ObservableObject {
    @Published private(set) var sources: [SourcesImprint] = []

    init(section: String) {
        let speciesDb = Connection.speciesDB
        self.sources = try! speciesDb.prepareRowIterator(SourcesImprint.Definition.table.filter(SourcesImprint.Definition.section == section)).map { row in
            SourcesImprint(
                id: row[SourcesImprint.Definition.id],
                section: row[SourcesImprint.Definition.section],
                scieName: row[SourcesImprint.Definition.scieName],
                scieNameEng: row[SourcesImprint.Definition.scieNameEng],
                imageSource: row[SourcesImprint.Definition.imageSource],
                licence: row[SourcesImprint.Definition.licence],
                author: row[SourcesImprint.Definition.author]
            )
        }
    }
}
    
