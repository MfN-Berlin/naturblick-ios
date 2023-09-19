//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupButton: View {

    let group: Group

    var body: some View {
        VStack() {
            Image(group.image).resizable()
                .resizable()
                .clipShape(Circle())
                .scaledToFit()
                .nbShadow()
            Text(group.gerName)
                .multilineTextAlignment(TextAlignment.center)
                .foregroundColor(.onPrimaryHighEmphasis)
                .font(.nbBody1)
            Spacer()
        }
    }
}

struct GroupButton_Previews: PreviewProvider {
    static var previews: some View {
        GroupButton(group: Group.groups[0])
    }
}
