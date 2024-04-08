//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct SourcesImprint: Identifiable {
    let id: Int64
    let scieName: String
    let scieNameEng: String
    let imageSource: String?
    let licence: String?
    let author: String?
}

extension SourcesImprint {
    struct Definition {
        static let table = Table("sources_imprint")
        static let id = Expression<Int64>("id")
        static let scieName = Expression<String>("scie_name")
        static let scieNameEng = Expression<String>("scie_name_eng")
        static let imageSource = Expression<String?>("image_source")
        static let licence = Expression<String?>("licence")
        static let author = Expression<String?>("author")
    }
    
    var text: String {
        var licence = ""
        if let text = self.licence {
            licence = " (\(text))"
        }
        var scieName = self.scieNameEng
        if isGerman() {
            scieName = self.scieName
        }
        var author = ""
        if let text = self.author {
            author = text
        }
        return "\(author)\(licence)\n\(scieName)"
    }
}
