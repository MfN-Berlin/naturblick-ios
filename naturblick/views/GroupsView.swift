//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct GroupsView: View {
    var body: some View {
        ZStack {
            Color
                .primary500
                .ignoresSafeArea()
            ScrollView {
                Image("artportraits24")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.sunset)
                    .frame(width: .headerIconSize, height: .headerIconSize)
                Text("Wähle eine Gruppe")
                    .font(.nbHeadline3)
                    .foregroundColor(.white)
                LazyVGrid(columns: [
                    GridItem(spacing: .defaultPadding),
                    GridItem(spacing: .defaultPadding),
                    GridItem(spacing: .defaultPadding)
                ], spacing: .defaultPadding) {
                        ForEach(Group.groups) { group in
                            GroupButton(group: group)
                        }
                    }.padding(.defaultPadding)
            }
        }
        .navigationTitle("Arten kennenlernen")
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupsView()
        }
    }
}
