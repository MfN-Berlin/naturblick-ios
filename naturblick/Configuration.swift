//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation

struct Configuration {
    #if DEBUG
    static let strapiUrl = "https://naturblick.museumfuernaturkunde.berlin/strapi/"
    static let backendUrl = "https://naturblick.museumfuernaturkunde.berlin/api/"
    #else
    static let strapiUrl = "https://naturblick.museumfuernaturkunde.berlin/strapi/"
    static let backendUrl = "https://naturblick.museumfuernaturkunde.berlin/api/"
    #endif
}
