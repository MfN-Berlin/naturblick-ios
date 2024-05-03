//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupsView<Content>: NavigatableView where Content: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "menu_groups")
    var viewType: GroupsViewType
    var alwaysDarkBackground: Bool = true
    let groups: [Group]
    let destination: (Group) -> Content
    
    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                Image("artportraits24")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.onPrimarySignalHigh)
                    .frame(width: .headerIconSize, height: .headerIconSize)
                    .padding(.top, .defaultPadding)
                Text("choose_a_group")
                    .headline3()
                    .padding(.bottom, .doublePadding)
                
                LazyVGrid(columns: [
                     GridItem(spacing: .defaultPadding, alignment: .center),
                     GridItem(spacing: .defaultPadding, alignment: .center),
                     GridItem(spacing: .defaultPadding, alignment: .center)
                 ], spacing: .defaultPadding) {
                     ForEach(groups.dropLast(groups.count % 3)) { group in
                         GroupButton(group: group).onTapGesture {
                             AnalyticsTracker.trackSpeciesSelection(filter: .group(group), viewType: self.viewType)
                             let nextViewController = destination(group).setUpViewController()
                             viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                         }
                     }
                 }.padding(.defaultPadding)
                
                
                
                // center overhanging elements
                if (groups.count % 3 > 0) {
                    HStack {
                        if(groups.count % 3 == 1) {
                            Spacer().frame(maxWidth: .infinity)
                        }
                        ForEach(0 ..< groups.count % 3, id: \.self) { group in
                            let group = groups[(groups.count / 3) * 3 + group]
                            GroupButton(group: group).onTapGesture {
                                AnalyticsTracker.trackSpeciesSelection(filter: .group(group), viewType: self.viewType)
                                let nextViewController = destination(group).setUpViewController()
                                viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                            }
                        }
                        Spacer().frame(maxWidth: .infinity)
                    }
                    .padding(.defaultPadding)
                    .offset(x: groups.count % 3 == 1 ? 0.0 : .avatarSize)
                }
            }
        }
    }
}

enum GroupsViewType {
    case characterKeys
    case portraitGroups
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
            GroupsView(viewType: .portraitGroups ,groups: Group.groups) { group in T(str: "Clicked on \(group.gerName)")
            }
        }
    }
}
