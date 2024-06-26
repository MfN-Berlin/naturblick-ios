//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupButton: View {
    let size: CGFloat
    let group: Group
    let action: () -> ()
    var body: some View {
        VStack(spacing: .defaultPadding) {
            Image(group.image)
                .resizable()
                .imageScale(.small)
                .clipShape(Circle())
                .scaledToFit()
                .padding(.horizontal, .halfPadding)
                .nbShadow()
            Text(text)
                .bigRoundButtonText(size: size)
            Spacer()
        }.accessibilityRepresentation {
            Button(text) {
                action()
            }
        }
        .onTapGesture {
            action()
        }
    }
    
    private var text: String {
        return isGerman() ? group.gerName : group.engName
    }
}

struct GroupButton_Previews: PreviewProvider {
    static var previews: some View {
        GroupButton(size: 500, group: Group.groups[0]) {}
    }
}
