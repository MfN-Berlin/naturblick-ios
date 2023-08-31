//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupsView<Content>: NavigatableView where Content: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var title: String? = "Arten kennenlernen"
    
    let groups: [Group]
    let destination: (Group) -> Content
    
    var body: some View {
        BaseView(oneColor: true) {
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
                        GroupButton(group: group).onTapGesture {
                            let nextViewController = destination(group).setUpViewController()
                            viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                        }
                    }
                }.padding(.defaultPadding)
            }
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    
    struct T : NavigatableView {
        let str: String
        
        var holder: ViewControllerHolder = ViewControllerHolder()
        
        var body: some View {
            Text("Clicked on \(str)")
        }
        
        
    }
    
    static var previews: some View {
        NavigationView {
            GroupsView(groups: Group.groups) { group in
                T(str: "Clicked on \(group.gerName)")
            }
        }
    }
}
