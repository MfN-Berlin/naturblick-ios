//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct GroupsView<Content>: View where Content: View {
    let groups: [Group]
    let destination: (Group) -> Content
    var body: some View {
        ZStack {
            Color
                .nbPrimary
                .ignoresSafeArea()
            ScrollView {
                Image("artportraits24")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.onPrimarySignalHigh)
                    .frame(width: .headerIconSize, height: .headerIconSize)
                Text("Wähle eine Gruppe")
                    .font(.nbHeadline3)
                    .foregroundColor(.white)
                LazyVGrid(columns: [
                    GridItem(spacing: .defaultPadding),
                    GridItem(spacing: .defaultPadding),
                    GridItem(spacing: .defaultPadding)
                ], spacing: .defaultPadding) {
                        ForEach(groups) { group in
                            NavigationLink(destination: destination(group)) {
                                GroupButton(group: group)
                            }
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
            GroupsView(groups: Group.groups) { group in
                Text("Clicked on \(group.gerName)")
            }
        }
    }
}
