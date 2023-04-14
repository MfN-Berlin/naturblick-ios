//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

enum HttpError: Error {
    case networkError
    case serverError
}

extension HttpError {
    var localizedDescription: String {
        switch(self) {
        case .networkError:
            return "Network error"
        case .serverError:
            return "Server error"
        }
    }
}
