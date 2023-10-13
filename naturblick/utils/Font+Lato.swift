//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

extension CGFloat {
    static let headline2: CGFloat = 36
    static let headline3: CGFloat = 30
    static let headline4: CGFloat = 25
    static let headline6: CGFloat = 19

    static let subtitle1: CGFloat = 16
    static let subtitle2: CGFloat = 14
    static let subtitle3: CGFloat = 14

    static let body1: CGFloat = 16
    static let body2: CGFloat = 14

    static let caption: CGFloat = 12
    static let button: CGFloat = 14
    static let overline: CGFloat = 12
}

extension Font {
    static let nbHeadline2 = Font.custom("Lato", size: .headline2, relativeTo: .title).weight(.black)
    static let nbHeadline3 = Font.custom("Lato", size: .headline3, relativeTo: .title).weight(.black)
    static let nbHeadline4 = Font.custom("Lato", size: .headline4, relativeTo: .title).weight(.black)
    static let nbHeadline6 = Font.custom("Lato", size: .headline6, relativeTo: .title).weight(.black)

    static let nbSubtitle1 = Font.custom("Lato", size: .subtitle1, relativeTo: .subheadline).weight(.black)
    static let nbSubtitle2 = Font.custom("Lato", size: .subtitle2, relativeTo: .subheadline).weight(.black)
    static let nbSubtitle3 = Font.custom("Lato", size: .subtitle3, relativeTo: .subheadline).italic()

    static let nbBody1 = Font.custom("Lato", size: .body1, relativeTo: .body)
    static let nbBody2 = Font.custom("Lato", size: .body2, relativeTo: .body)

    static let nbCaption = Font.custom("Lato", size: .caption, relativeTo: .caption)

    static let nbButton = Font.custom("Lato", size: .button, relativeTo: .body)
    static let nbOverline = Font.custom("Lato", size: .overline, relativeTo: .subheadline).italic()
}

extension Text {
    func headline2() -> some View {
        self.font(.nbHeadline2)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
    
    func headline3() -> some View {
        self
            .font(.nbHeadline3)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
    
    func headline4(color: Color) -> some View {
        self
            .font(.nbHeadline4)
            .foregroundColor(color)
    }
    
    func headline4() -> some View {
        headline4(color: .onSecondaryHighEmphasis)
    }
    
    func headline6() -> some View {
        self.font(.nbHeadline6)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
    
    func subtitle1() -> some View {
        subtitle1(color: .onSecondaryHighEmphasis)
    }
    
    func subtitle1(color: Color) -> some View {
        self.font(.nbSubtitle1)
            .foregroundColor(color)
    }
    
    func subtitle3() -> some View {
        self.font(.nbSubtitle3)
            .kerning(0.018 * .subtitle3)
            .foregroundColor(Color.onSecondarySignalLow)
    }
    
    func subtitle3(color: Color) -> some View {
        self.font(.nbSubtitle3)
            .foregroundColor(color)
    }
    
    func body1(color: Color) -> some View {
        self.font(.nbBody1)
            .foregroundColor(color)
    }
    
    func body1() -> some View {
        body1(color: .onSecondaryMediumEmphasis)
    }
    
    func body2() -> some View {
        body2(color: .onSecondaryMediumEmphasis)
    }
    
    func body2(color: Color) -> some View {
        self.font(.nbBody2)
            .foregroundColor(color)
    }
    
    func caption() -> some View {
        caption(color: .onPrimaryButtonSecondary)
    }
    
    func caption(color: Color) -> some View {
        self.font(.caption)
            .kerning(0.04 * .caption)
            .foregroundColor(color)
    }
    
    func button() -> Text {
        self.font(.nbButton)
            .kerning(0.018 * .button)
    }
    
    func overline(color: Color) -> some View {
        self
            .font(.nbOverline)
            .kerning(0.042 * .overline)
            .foregroundColor(color)
    }
}
