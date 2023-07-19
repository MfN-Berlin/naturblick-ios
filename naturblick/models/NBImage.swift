//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

struct NBImage {
    let id: UUID
    let image: UIImage
    
    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
    }
}
