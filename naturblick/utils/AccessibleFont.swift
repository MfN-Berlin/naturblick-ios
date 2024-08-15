//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct AccessibleFont {
    var regular: Font
    var bold: Font

    init(regular: Font, bold: Font) {
        self.regular = regular
        self.bold = bold
    }

    func value(_ legibilityWeight: LegibilityWeight?) -> Font {
        switch legibilityWeight {
        case .bold:
            return bold
        default:
            return regular
        }
    }
}

extension AccessibleFont {
    static var nbBody1: AccessibleFont {
        AccessibleFont(
            regular: Font.custom("Lato", size: .body1, relativeTo: .body).weight(.regular).leading(.tight),
            bold: Font.custom("Lato", size: .body1, relativeTo: .body).weight(.black).leading(.tight)
        )
    }
    
    static var nbBody2: AccessibleFont {
        AccessibleFont(
            regular: Font.custom("Lato", size: .body2, relativeTo: .body).leading(.tight).weight(.regular),
            bold: Font.custom("Lato", size: .body2, relativeTo: .body).leading(.tight).weight(.black)
        )
    }
    
    static var nbHeadline2: AccessibleFont {
        var f = Font.custom("Lato", size: .headline2, relativeTo: .title).weight(.black).leading(.tight)
        return AccessibleFont(regular: f, bold: f)
    }
    
    static var nbHeadline3: AccessibleFont {
        var f = Font.custom("Lato", size: .headline3, relativeTo: .title).weight(.black).leading(.tight)
        return AccessibleFont(regular: f, bold: f)
    }
    
    static var nbHeadline4: AccessibleFont {
        var f = Font.custom("Lato", size: .headline4, relativeTo: .title).weight(.black).leading(.tight)
        return AccessibleFont(regular: f, bold: f)
    }
    
    static var nbHeadline6: AccessibleFont {
        var f = Font.custom("Lato", size: .headline6, relativeTo: .title).weight(.black).leading(.tight)
        return AccessibleFont(regular: f, bold: f)
    }
    
    static var nbSubtitle1: AccessibleFont {
        var f = Font.custom("Lato", size: .subtitle1, relativeTo: .subheadline).weight(.black).leading(.tight)
        return AccessibleFont(regular: f, bold: f)
    }
    
    static var nbSubtitle2: AccessibleFont {
        var f = Font.custom("Lato", size: .subtitle2, relativeTo: .subheadline).weight(.black).leading(.tight)
        return AccessibleFont(regular: f, bold: f)
    }

    static var nbSubtitle3: AccessibleFont {
        var f = Font.custom("Lato", size: .subtitle3, relativeTo: .subheadline).italic().leading(.tight)
        return AccessibleFont(
            regular: f.weight(.regular),
            bold: f.weight(.black)
        )
    }
    
    static var nbCaption: AccessibleFont {
        var f = Font.custom("Lato", size: .caption, relativeTo: .caption).leading(.tight)
        return AccessibleFont(
            regular: f.weight(.regular),
            bold: f.weight(.black)
        )
    }
    
    static var nbButton: AccessibleFont {
        var f = Font.custom("Lato", size: .button, relativeTo: .body)
        return AccessibleFont(
            regular: f.weight(.regular),
            bold: f.weight(.black)
        )
    }
    
    static var nbOverline: AccessibleFont {
        var f = Font.custom("Lato", size: .overline, relativeTo: .subheadline).italic().leading(.tight)
        return AccessibleFont(
            regular: f.weight(.regular),
            bold: f.weight(.black)
        )
    }
}

struct AccessibilityFontViewModifier: ViewModifier {
    @Environment(\.legibilityWeight) private var legibilityWeight

    var font: AccessibleFont

    func body(content: Content) -> some View {
        content.font(font.value(legibilityWeight))
    }
}

extension View {
    func accessibilityFont(_ font: AccessibleFont) -> some View {
        return self.modifier(AccessibilityFontViewModifier(font: font))
    }
}

