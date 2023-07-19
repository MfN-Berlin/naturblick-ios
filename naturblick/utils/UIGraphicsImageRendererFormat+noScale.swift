//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

extension UIGraphicsImageRendererFormat {
    static let noScale: UIGraphicsImageRendererFormat = {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return format
    }()
}
