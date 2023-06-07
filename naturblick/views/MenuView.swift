//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct MenuView: View {
    
    @Binding var navigateTo: AnyView?
    @Binding var isNavigationActive: Bool
    
    static let fieldbookDestination = ObservationListView(obsAction: .createManualObservation)
    static let imageIdDest = ObservationListView(obsAction: .createImageObservation)
    static let portraitDest = GroupsView(
        groups: Group.groups,
        destination: { group in
            SpeciesListView(filter: .group(group))
        }
    )
    static let charactersDest =  GroupsView(
        groups: Group.characterGroups,
        destination: { group in
            CharactersView(group: group)
        }
    )
    static let aboutDest = AboutView()
    static let imprintDest = ImprintView()
    
    var body: some View {
        Menu {
            Button("Fieldbook", action: {
                navigateTo = AnyView(MenuView.fieldbookDestination)
                isNavigationActive = true
            })
            Button("Record a bird sound", action: toDo)
            Button("Photograph a plant", action: {
                navigateTo = AnyView(MenuView.imageIdDest)
                isNavigationActive = true
            })
            Button("Help", action: toDo)
            Divider()
            Button("Account", action: toDo)
            Button("Settings", action: toDo)
            Button("Feedback", action: toDo)
            Button("Imprint", action: {
                navigateTo = AnyView(MenuView.imprintDest)
                isNavigationActive = true
            })
            Button("About Naturblick", action: {
                navigateTo = AnyView(MenuView.aboutDest)
                isNavigationActive = true
            })
        } label: {
            Image(systemName: "ellipsis")
        }
    }

    func toDo() {
        navigateTo = AnyView(Text("ToDo"))
        isNavigationActive = true
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(navigateTo: .constant(AnyView(Text("foo"))), isNavigationActive: .constant(false))
    }
}
