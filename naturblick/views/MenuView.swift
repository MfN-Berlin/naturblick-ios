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
    
    var body: some View {
        Menu {
            Button("Feldbuch", action: {
                navigateTo = AnyView(MenuView.fieldbookDestination)
                isNavigationActive = true
            })
            Button("Vogelstimmen aufnehmen", action: toDo)
            Button("Pflanze fotografieren", action: {
                navigateTo = AnyView(MenuView.imageIdDest)
                isNavigationActive = true
            })
            Button("Hilfe", action: toDo)
            Divider()
            Button("Account", action: toDo)
            Button("Einstellungen", action: toDo)
            Button("Feedback", action: toDo)
            Button("Impressum", action: toDo)
            Button("Über Naturblick", action: toDo)
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
