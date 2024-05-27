//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupsView<Content>: NavigatableView where Content: UIViewController {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "menu_groups")
    var viewType: GroupsViewType
    var alwaysDarkBackground: Bool = true
    let groups: [Group]
    let destination: (Group) -> Content
    
    var body: some View {
        GeometryReader { geo in
            let width = min(geo.size.width, .maxContentWidth)
            ScrollView {
                VStack {
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
                        GridItem(spacing: .defaultPadding, alignment: .top),
                        GridItem(spacing: .defaultPadding, alignment: .top),
                        GridItem(spacing: .defaultPadding, alignment: .top)
                    ], spacing: .defaultPadding) {
                        ForEach(groups) { group in
                            GroupButton(size: (geo.size.width - 4 * .defaultPadding) / 3, group: group).onTapGesture {
                                AnalyticsTracker.trackSpeciesSelection(filter: .group(group), viewType: self.viewType)
                                let nextViewController = destination(group)
                                viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                            }
                        }
                    }
                    .frame(maxWidth: width)
                    .padding(.defaultPadding)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

enum GroupsViewType {
    case characterKeys
    case portraitGroups
}

struct GroupsView_Previews: PreviewProvider {
    
    class TController: HostingController<T> {
        init(str: String) {
            super.init(rootView: T(str: str))
        }
    }
    
    struct T : HostedView {
        let str: String
        
        var holder: ViewControllerHolder = ViewControllerHolder()
        
        var body: some View {
            Text("Clicked on \(str)")
        }
        
        
    }
    
    static var previews: some View {
        NavigationView {
            GroupsView(viewType: .portraitGroups ,groups: Group.groups) { group in
                TController(str: "Clicked on \(group.gerName)")
            }
        }
    }
}
