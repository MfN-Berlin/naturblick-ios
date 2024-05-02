//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import os

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let compat = Logger(subsystem: subsystem, category: "compat")
}
