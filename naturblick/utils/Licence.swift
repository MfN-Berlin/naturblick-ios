//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct License {
    
    public static func licenseToLink(license: String) -> String {
        let l = license.lowercased()
        
        if l.contains("cc0") || l.contains("cc 0") {
            return "[\(license)](https://creativecommons.org/publicdomain/zero/1.0) "
        }
        else if l.contains("cc") && l.contains("by") {
            return "[\(license)](https://creativecommons.org/licenses/by\(sa(l))/\(version(l)))"
        }
        else {
            return "(\(license)) "
        }
    }
    
    private static func sa(_ license: String) -> String {
        if license.contains("sa") {
            return "-sa"
        }
        else {
            return ""
        }
    }

    private static func version(_ license: String) -> String {
        if license.contains("1.0") {
            return "1.0"
        }
        else if license.contains("2.0") {
            return "2.0"
        }
        else if license.contains("2.5") {
            return "2.5"
        }
        else if license.contains("3.0") {
            return "3.0"
        }
        else if license.contains("4.0") {
            return "4.0"
        }
        else {
            return  ""
        }
    }
}
