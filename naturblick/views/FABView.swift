//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct FABView: View {
    let image: Image
    
    init(_ asset: String) {
        self.image = Image(asset)
    }
    
    init(systemName: String) {
        self.image = Image(systemName: systemName)
    }
    
    var body: some View {
        Circle()
            .fill(Color.primaryColor)
            .overlay {
                image
                .resizable()
                .scaledToFit()
                .foregroundColor(.onPrimaryHighEmphasis)
                .padding(.fabIconPadding)
            }
            .frame(width: .fabSize)
    }
}

struct FABView_Previews: PreviewProvider {
    static var previews: some View {
        FABView("placeholder")
    }
}
