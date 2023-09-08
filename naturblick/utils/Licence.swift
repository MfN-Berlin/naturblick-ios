//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct Licence {
    
    public static func licenceToLink(licence: String) -> String {
        let l = licence.lowercased()
        
        if l.contains("cc0") || l.contains("cc 0") {
            return "[\(licence)](https://creativecommons.org/publicdomain/zero/1.0) "
        }
        else if l.contains("cc") && l.contains("by") {
            return "[\(licence)](https://creativecommons.org/licenses/by\(sa(l))/\(version(l)))"
        }
        else {
            return "(\(licence)) "
        }
    }
    
    private static func sa(_ licence: String) -> String {
        if licence.contains("sa") {
            return "-sa"
        }
        else {
            return ""
        }
    }

    private static func version(_ licence: String) -> String {
        if licence.contains("1.0") {
            return "1.0"
        }
        else if licence.contains("2.0") {
            return "2.0"
        }
        else if licence.contains("2.5") {
            return "2.5"
        }
        else if licence.contains("3.0") {
            return "3.0"
        }
        else if licence.contains("4.0") {
            return "4.0"
        }
        else {
            return  ""
        }
    }
}
