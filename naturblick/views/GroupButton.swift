//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct GroupButton: View {

    let group: Group

    var body: some View {
        NavigationLink(destination: SpeciesListView(filter: .group(group))) {
            VStack() {
                Image(group.image).resizable()
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFit()
                Text(group.gerName)
                    .multilineTextAlignment(TextAlignment.center)
                    .foregroundColor(.white)
                    .font(.nbBody1)
                Spacer()
            }
        }
    }
}

struct GroupButton_Previews: PreviewProvider {
    static var previews: some View {
        GroupButton(group: Group.groups[0])
    }
}
