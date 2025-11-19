//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

enum FabSize {
    case normal
    case mini
}

struct FABView: View {
    let image: Image
    let color: Color
    let size: FabSize
    init(_ asset: String, color: Color = Color.primaryColor, size: FabSize = .normal) {
        self.image = Image(asset)
        self.color = color
        self.size = size
    }
    
    init(systemName: String, color: Color = Color.primaryColor, size: FabSize = .normal) {
        self.image = Image(systemName: systemName)
        self.color = color
        self.size = size
    }
    
    var viewSize: CGFloat {
        switch(size) {
        case .normal:
            return .fabSize
        case .mini:
            return .fabMiniSize
        }
    }
    var paddingSize: CGFloat {
        switch(size) {
        case .normal:
            return .fabIconPadding
        case .mini:
            return .fabIconMiniPadding
        }
    }
    var body: some View {
        Circle()
            .fill(color)
            .overlay {
                image
                .resizable()
                .scaledToFit()
                .foregroundColor(.onPrimaryHighEmphasis)
                .padding(paddingSize)
            }
            .frame(width: viewSize, height: viewSize)
            .nbShadow()
    }
}

struct FABView_Previews: PreviewProvider {
    static var previews: some View {
        FABView("placeholder")
    }
}
