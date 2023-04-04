//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import Foundation

enum SpeciesListFilter {
    case group(Group)
    case characters(Int, [(Int64, Float)])
}
