//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

extension Font {
    static let nbHeadline2 = Font.custom("Lato", size: 36, relativeTo: .title).weight(.black)
    static let nbHeadline3 = Font.custom("Lato", size: 30, relativeTo: .title).weight(.black)
    static let nbHeadline4 = Font.custom("Lato", size: 25, relativeTo: .title).weight(.black)
    static let nbHeadline6 = Font.custom("Lato", size: 19, relativeTo: .title).weight(.black)

    static let nbSubtitle1 = Font.custom("Lato", size: 16, relativeTo: .subheadline).weight(.black)
    static let nbSubtitle2 = Font.custom("Lato", size: 14, relativeTo: .subheadline).weight(.black)
    static let nbSubtitle3 = Font.custom("Lato", size: 14, relativeTo: .subheadline).italic()

    static let nbBody1 = Font.custom("Lato", size: 16, relativeTo: .body)
    static let nbBody2 = Font.custom("Lato", size: 14, relativeTo: .body)

    static let nbCaption = Font.custom("Lato", size: 12, relativeTo: .caption)

    static let nbButton = Font.custom("Lato", size: 14, relativeTo: .body)
    static let nbOverline = Font.custom("Lato", size: 12, relativeTo: .subheadline).italic()
}
