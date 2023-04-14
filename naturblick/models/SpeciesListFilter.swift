//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation

enum SpeciesListFilter {
    case group(Group)
    case characters(Int, [(Int64, Float)])
}
