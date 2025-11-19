//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

extension CGFloat {
    static let defaultPadding: CGFloat = 14
    static let halfPadding: CGFloat = defaultPadding * 0.5
    static let doublePadding: CGFloat = defaultPadding * 2
    static let avatarSize: CGFloat = 64
    static let fabSize: CGFloat = 48
    static let fabMiniSize: CGFloat = 40
    static let fabMicroSize: CGFloat = 24
    static let fabIconPadding: CGFloat = 12
    static let fabIconMiniPadding: CGFloat = 8
    static let fabIconMicroPadding: CGFloat = 6
    static let avatarTextOffset: CGFloat = (avatarSize - .subtitle1LineHeight - .subtitle3LineHeight) / 2
    static let avatarOffsetPadding: CGFloat = 20
    static let headerIconSize: CGFloat = 24
    static let smallCornerRadius: CGFloat = 4
    static let largeCornerRadius: CGFloat = 8
    static let checkedSize: CGFloat = 20
    static let editTextIconSize: CGFloat = 24
    static let topRowFactor: CGFloat = 0.25
    static let bottomRowFactor: CGFloat = 0.21
    static let maxContentWidth: CGFloat = 700
    static let bigRoundButtonThreshold = bottomRowFactor * maxContentWidth
    static let goodToKnowLineWidth: CGFloat = 2
    static let mapInfoSize: CGFloat = 250
    static let stopButtonCircleSize: CGFloat = 116
    static let stopButtonSize: CGFloat = 44
    static let pixelToMsFactor: CGFloat = 10
    static let editTextFieldHeight: CGFloat = .editTextIconSize + 2 * .defaultPadding
    static let chevron: CGFloat = 24
    static let roundBottomHeight: CGFloat = 30
    static let leftRightQuadHeightFactor: CGFloat = 0.2
    
}

extension CGSize {
    static let thumbnail = CGSize(width: 448, height: 448)
}

extension Int {
    static let menuRowHeight: Int = 50
}
