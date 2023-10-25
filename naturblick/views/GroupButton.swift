//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupButton: View {

    let group: Group
    let geo: GeometryProxy

    var body: some View {
        VStack(spacing: .defaultPadding) {
            Image(group.image)
                .resizable()
                .imageScale(.small)
                .clipShape(Circle())
                .scaledToFit()
                .frame(width: geo.size.width * .topRowFactor)
                .nbShadow()
            Text(isGerman() ? group.gerName : group.engName)
                .caption(color: .onPrimaryHighEmphasis)
                .multilineTextAlignment(TextAlignment.center)
            Spacer()
        }
    }
}

struct GroupButton_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            GroupButton(group: Group.groups[0], geo: geo)
        }
    }
}
