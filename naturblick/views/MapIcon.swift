//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct MapIcon: View {
    
    let mapIcon: String
    
    init(mapIcon: String?) {
        self.mapIcon = mapIcon ?? "map_undefined_spec"
    }
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.onPrimaryHighEmphasis, lineWidth: CGFloat.goodToKnowLineWidth)
                .background(Circle().fill(Color.onPrimaryButtonPrimary))
                .frame(width: .headerIconSize, height: .headerIconSize)
                .overlay {
                    Image(mapIcon).foregroundColor(.onPrimaryHighEmphasis)
                }
        }
    }
}

#Preview {
    MapIcon(mapIcon: "map_undefined_spec")
}
