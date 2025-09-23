//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupButton: View {
    let size: CGFloat
    let group: NamedGroup
    let action: () -> ()
    var body: some View {
        VStack(spacing: .defaultPadding) {
            Image("group_conifer")
                .resizable()
                .imageScale(.small)
                .clipShape(Circle())
                .scaledToFit()
                .padding(.horizontal, .halfPadding)
                .nbShadow()
            Text(group.name)
                .bigRoundButtonText(size: size)
            Spacer()
        }.accessibilityRepresentation {
            Button(group.name) {
                action()
            }
        }
        .onTapGesture {
            action()
        }
    }
}

struct GroupButton_Previews: PreviewProvider {
    static var previews: some View {
        GroupButton(size: 500, group: NamedGroup.exampleData) {}
    }
}
