//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct FABView: View {
    let image: Image
    let color: Color
    init(_ asset: String, color: Color = Color.primaryColor) {
        self.image = Image(asset)
        self.color = color
    }
    
    init(systemName: String, color: Color = Color.primaryColor) {
        self.image = Image(systemName: systemName)
        self.color = color
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .overlay {
                image
                .resizable()
                .scaledToFit()
                .foregroundColor(.onPrimaryHighEmphasis)
                .padding(.fabIconPadding)
            }
            .frame(width: .fabSize, height: .fabSize)
            .nbShadow()
    }
}

struct FABView_Previews: PreviewProvider {
    static var previews: some View {
        FABView("placeholder")
    }
}
