//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct GroupsView: View {
    
    let grid = Group.groups.reduce(into: [[]]) { acc, iter in
        acc[acc.count - 1].count < 3
        ? acc[acc.count - 1 ].append(iter)
        : acc.append([iter])
    }
    
    var body: some View {
        ZStack {
            Color
                .primary_500
                .ignoresSafeArea()
            ScrollView {
                Image("artportraits24")
                Text("Wähle eine Gruppe")
                    .foregroundColor(.white)
                GeometryReader { geo in
                    VStack {
                        ForEach(grid, id: \.self) { row in
                            HStack(spacing: 16) {
                                ForEach(row) { group in
                                    GroupButton(group: group)
                                        .frame(width: geo.size.width / 3.3)
                                }
                            }
                        }
                    }.navigationTitle("Arten kennenlernen")
                }
            }.padding(10)
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupsView()
        }
    }
}
