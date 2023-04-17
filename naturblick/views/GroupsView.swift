//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupsView<Content>: View where Content: View {
    
    let groups: [Group]
    let destination: (Group) -> Content
    
    var body: some View {
        BaseView(navTitle: "Arten kennenlernen", oneColor: true) {
            ScrollView {
                Image("artportraits24")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.onPrimarySignalHigh)
                    .frame(width: .headerIconSize, height: .headerIconSize)
                Text("Wähle eine Gruppe")
                    .font(.nbHeadline3)
                    .foregroundColor(.onPrimaryHighEmphasis)
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
