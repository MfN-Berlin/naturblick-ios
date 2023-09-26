//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

extension CGFloat {
    static let defaultPadding: CGFloat = 14
    static let halfPadding: CGFloat = defaultPadding * 0.5
    static let avatarSize: CGFloat = 64
    static let fabSize: CGFloat = 48
    static let fabMiniSize: CGFloat = 24
    static let fabIconPadding: CGFloat = 12
    static let fabIconMiniPadding: CGFloat = 6
    static let avatarTextOffset: CGFloat = 12
    static let avatarOffsetPadding: CGFloat = 20
    static let headerIconSize: CGFloat = 24
    static let smallCornerRadius: CGFloat = 4
    static let largeCornerRadius: CGFloat = 8
    static let checkedSize: CGFloat = 20
    static let roundBottomHeight: CGFloat = 30
    static let editTextIconSize: CGFloat = 24
    static let topRowFactor: CGFloat = 0.25
    static let bottomRowFactor: CGFloat = 0.2
    static let goodToKnowLineWidth: CGFloat = 2
    static let mapInfoSize: CGFloat = 250
}

extension CGSize {
    static let thumbnail = CGSize(width: 448, height: 448)
}

extension Int {
    static let menuWidth: Int = 250
    static let menuRowHeight: Int = 50
}
