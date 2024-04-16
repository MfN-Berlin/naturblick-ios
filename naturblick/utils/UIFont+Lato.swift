//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import UIKit

extension UIFont {
    
    static let nbHeadline6 = UIFont(descriptor: UIFontDescriptor(fontAttributes: [
        UIFontDescriptor.AttributeName.family: "Lato",
        UIFontDescriptor.AttributeName.traits: [
            UIFontDescriptor.TraitKey.weight: UIFont.Weight.black
        ] as [UIFontDescriptor.TraitKey : Any]
    ]), size: 19)
    
    static let nbBody1 = UIFont(descriptor: UIFontDescriptor(fontAttributes: [
        UIFontDescriptor.AttributeName.family: "Lato",
        UIFontDescriptor.AttributeName.traits: [
            UIFontDescriptor.TraitKey.weight: UIFont.Weight.regular
        ] as [UIFontDescriptor.TraitKey : Any]
    ]), size: 16)
}
