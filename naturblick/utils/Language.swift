//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation

let German = "de"
let English = "en"

func isGerman() -> Bool {
    if Locale.current.languageCode == German {
        return true
    }
    return false;
}

func getLanguage() -> String {
    switch Locale.current.languageCode {
        case "de": return German
        default: return English
    }
}
