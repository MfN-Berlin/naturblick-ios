//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation

extension URL {
    private static let deBaseUrl = "https://de.wikipedia.org"
    private static let enBaseUrl = "https://en.wikipedia.org"

        private static func wikiName(sciname: String) -> String? {
            let tokens = sciname.split(separator: " ").prefix(2)
            if(tokens[0].lowercased() == "Gattung".lowercased()) {
                return nil
            } else {
                return tokens.joined(separator: "_").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            }
        }

        static func wikipedia(species: SpeciesListItem) -> URL? {
            let wikiName = URL.wikiName(sciname: species.sciname)
            if (isGerman()) {
                if let wikipedia = species.wikipedia {
                    return URL(string: wikipedia)
                } else if let name = wikiName {
                    return URL(string: "\(URL.deBaseUrl)/wiki/\(name)")
                } else {
                    return nil
                }
            } else {
                if let name = wikiName {
                    return URL(string: "\(URL.enBaseUrl)/wiki/\(name)")
                } else {
                    return nil
                }
            }
        }
}
