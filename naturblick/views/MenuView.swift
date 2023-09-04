//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct MenuView: View {
    @Binding var navigateTo: NavigationDestination?
    
    var body: some View {
        Menu {
            Button("Fieldbook") {
                navigateTo = .fieldbook
            }
            Button("Record a bird sound") {
                navigateTo = .birdId
            }
            Button("Photograph a plant") {
                navigateTo = .plantId
            }
            Button("Help")  {
                navigateTo = .help
            }
            Divider()
            Button("Account") {
                navigateTo = .account
            }
            Button("Settings") {
                navigateTo = .settings
            }
            Button("Feedback") {
                navigateTo = .feedback
            }
            Button("Imprint") {
                navigateTo = .imprint
            }
            Button("About Naturblick") {
                navigateTo = .about
            }
        } label: {
            Image(systemName: "gearshape")
                .foregroundColor(.onPrimaryHighEmphasis)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(navigateTo: .constant(nil))
    }
}
