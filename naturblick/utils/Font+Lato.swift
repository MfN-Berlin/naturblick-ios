//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

extension CGFloat {
    static let headline2: CGFloat = 36
    static let headline2LineHeight: CGFloat = 40
    static let headline3: CGFloat = 30
    static let headline3LineHeight: CGFloat = 36
    static let headline4: CGFloat = 25
    static let headline4LineHeight: CGFloat = 30
    static let headline6: CGFloat = 19
    static let headline6LineHeight: CGFloat = 27

    static let subtitle1: CGFloat = 16
    static let subtitle1LineHeight: CGFloat = 22

    static let subtitle2: CGFloat = 14
    static let subtitle2LineHeight: CGFloat = 24

    static let subtitle3: CGFloat = 14
    static let subtitle3LineHeight: CGFloat = 22

    static let body1: CGFloat = 16
    static let body1LineHeight: CGFloat = 24

    static let body2: CGFloat = 14
    static let body2LineHeight: CGFloat = 20


    static let caption: CGFloat = 12
    static let captionLineHeight: CGFloat = 16

    static let button: CGFloat = 14

    static let overline: CGFloat = 12
    static let overlineLineHeight: CGFloat = 17

    static func spacing(fontSize: CGFloat, lineHeight: CGFloat) -> CGFloat {
        lineHeight - (fontSize + 2) // A font with leading(.tight) is 2 points bigger than its font size
    }
}

extension Text {
    private func lineSpacing(fontSize: CGFloat, lineHeight: CGFloat) -> some View {
        let lineSpacing: CGFloat = .spacing(fontSize: fontSize, lineHeight: lineHeight)
        return self
            .lineSpacing(lineSpacing)
            .padding([.bottom, .top], lineSpacing / 2.0)
    }
    
    func headline2() -> some View {
        self.lineSpacing(fontSize: .headline2, lineHeight: .headline2LineHeight)
            .accessibilityFont(.nbHeadline2)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
    
    func headline3() -> some View {
        self.lineSpacing(fontSize: .headline3, lineHeight: .headline3LineHeight)
            .accessibilityFont(.nbHeadline3)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
    
    func headline4(color: Color) -> some View {
        self.lineSpacing(fontSize: .headline4, lineHeight: .headline4LineHeight)
            .accessibilityFont(.nbHeadline4)
            .foregroundColor(color)
    }
    
    func headline4() -> some View {
        headline4(color: .onSecondaryHighEmphasis)
    }
    
    func headline6() -> some View {
        self.headline6(color: .onPrimaryHighEmphasis)
    }

    func headline6(color: Color) -> some View {
        self.lineSpacing(fontSize: .headline6, lineHeight: .headline6LineHeight)
            .accessibilityFont(.nbHeadline6)
            .foregroundColor(color)
    }
    
    func subtitle1() -> some View {
        subtitle1(color: .onSecondaryHighEmphasis)
    }
    
    func subtitle1(color: Color) -> some View {
        self.lineSpacing(fontSize: .subtitle1, lineHeight: .subtitle1LineHeight)
            .accessibilityFont(.nbSubtitle1)
            .foregroundColor(color)
    }
    
    func subtitle3() -> some View {
            subtitle3(color: Color.onSecondarySignalLow)
    }
    
    func subtitle3(color: Color) -> some View {
        self.kerning(0.018 * .subtitle3)
            .lineSpacing(fontSize: .subtitle3, lineHeight: .subtitle3LineHeight)
            .accessibilityFont(.nbSubtitle3)
            .foregroundColor(color)
    }
    
    func body1(color: Color) -> some View {
        self.lineSpacing(fontSize: .body1, lineHeight: .body1LineHeight)
            .accessibilityFont(.nbBody1)
            .foregroundColor(color)
    }
    
    func body1() -> some View {
        body1(color: .onSecondaryMediumEmphasis)
    }
    
    func body2() -> some View {
        body2(color: .onSecondaryMediumEmphasis)
    }
    
    func body2(color: Color) -> some View {
        self.lineSpacing(fontSize: .body2, lineHeight: .body2LineHeight)
            .accessibilityFont(.nbBody2)
            .foregroundColor(color)
    }
    
    func caption() -> some View {
        caption(color: .onPrimaryButtonSecondary)
    }
    
    func caption(color: Color) -> some View {
        self.kerning(0.04 * .caption)
            .lineSpacing(fontSize: .caption, lineHeight: .captionLineHeight)
            .accessibilityFont(.nbCaption)
            .foregroundColor(color)
    }
    
    func button() -> some View {
        self.kerning(0.018 * .button)
            .accessibilityFont(.nbButton)
    }
    
    func overline(color: Color) -> some View {
        self.kerning(0.042 * .overline)
            .lineSpacing(fontSize: .overline, lineHeight: .overlineLineHeight)
            .accessibilityFont(.nbOverline)
            .foregroundColor(color)
    }
    
    func bigRoundButtonText(size: CGFloat) -> some View {
        let isBig = size >= CGFloat.bigRoundButtonThreshold
        return self
            .kerning(0.04 * (isBig ? .body1 : .caption))
            .lineSpacing(fontSize: isBig ? .body1 : .caption, lineHeight: isBig ? .body1LineHeight : .captionLineHeight)
            .accessibilityFont(isBig ? .nbBody1 : .nbCaption)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
}
