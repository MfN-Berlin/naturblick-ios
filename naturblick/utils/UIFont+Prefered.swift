//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import UIKit

extension UIFont {
    
    class func preferredFont(forTextStyle style: UIFont.TextStyle, fontName: String = "Lato", weight: Weight = .regular, size: CGFloat) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)

        let fontToScale: UIFont
        if let font = UIFont(name: fontName, size: size ) {
            fontToScale = font
        } else {
            fontToScale = UIFont.systemFont(ofSize: size, weight: weight)
        }
        return metrics.scaledFont(for: fontToScale)
    }
}
