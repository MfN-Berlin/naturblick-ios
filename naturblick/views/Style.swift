//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

extension Text {
    func subtitle1() -> some View {
        self.font(.nbSubtitle1)
            .foregroundColor(.onSecondaryHighEmphasis)
    }
    
    func subtitle3() -> some View {
        self.font(.nbSubtitle3)
            .foregroundColor(Color.onSecondarySignalLow)
    }
    
    func subtitle3(color: Color) -> some View {
        self.font(.nbSubtitle3)
            .foregroundColor(color)
    }
    
    func body2() -> some View {
        self.font(.nbBody2)
            .foregroundColor(.onSecondaryMediumEmphasis)
    }
    
    func caption() -> some View {
        self.font(.nbCaption)
            .foregroundColor(.onPrimaryButtonSecondary)
    }
    
    func caption(color: Color) -> some View {
        self.font(.nbCaption)
            .foregroundColor(color)
    }
    
    func headline6() -> some View {
        self.font(.nbHeadline6)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
    
    func button() -> some View {
        self.font(.nbButton)
            .foregroundColor(.onPrimaryHighEmphasis)
    }
}
