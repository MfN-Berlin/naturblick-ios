//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

extension UUID {
    func filename(mime: MimeType) -> String {
        switch(mime) {
        case .jpeg:
            return "naurblick_\(uuidString.lowercased()).jpg"
        case .mp4:
            return "naurblick_\(uuidString.lowercased()).mp4"
        }
    }
}
