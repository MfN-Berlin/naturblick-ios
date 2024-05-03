//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GroupsView<Content>: NavigatableView where Content: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "menu_groups")
    var viewType: GroupsViewType
    var alwaysDarkBackground: Bool = true
    let destination: (Group) -> Content
    
    func button(_ group: Group) -> some View {
        GroupButton(group: group).onTapGesture {
            AnalyticsTracker.trackSpeciesSelection(filter: .group(group), viewType: self.viewType)
            let nextViewController = destination(group).setUpViewController()
            viewController?.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    var body: some View {
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
                if case .portraitGroups = viewType {
                    VStack(spacing: .defaultPadding) {
                        HStack(spacing: .defaultPadding) {
                            button(.amphibian)
                            button(.hymenoptera)
                            button(.conifer)
                        }
                        HStack(spacing: .defaultPadding) {
                            button(.herb)
                            button(.tree)
                            button(.reptile)
                        }
                        HStack(spacing: .defaultPadding) {
                            button(.butterfly)
                            button(.gastropoda)
                            button(.mammal)
                        }
                        HStack(spacing: .defaultPadding) {
                            Spacer().frame(maxWidth: .infinity)
                            button(.bird)
                            Spacer().frame(maxWidth: .infinity)
                        }
                    }.padding(.defaultPadding)
                } else {
                    VStack(spacing: .defaultPadding) {
                        HStack(spacing: .defaultPadding) {
                            button(.amphibian)
                            button(.hymenoptera)
                            button(.herb)
                        }
                        HStack(spacing: .defaultPadding) {
                            button(.tree)
                            button(.reptile)
                            button(.butterfly)
                        }
                        HStack(spacing: .defaultPadding) {
                            button(.gastropoda)
                            button(.mammal)
                            button(.bird)
                        }
                    }.padding(.defaultPadding)
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
            GroupsView(viewType: .portraitGroups) { group in
                T(str: "Clicked on \(group.gerName)")
            }
        }
    }
}
