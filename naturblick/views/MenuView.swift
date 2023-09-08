//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct MenuView: View {
    @Binding var navigateTo: NavigationDestination?
    
    var body: some View {
        Menu {
            Button(action: {
                navigateTo = .help
            }) {
                Label("Help", systemImage: "questionmark.circle")
            }
            Button(action: {
                navigateTo = .account
            }) {
                Label("Account", systemImage: "person")
            }
            Button(action: {
                navigateTo = .settings
            }) {
                Label("Settings", systemImage: "gearshape")
            }
            Button(action: {
                navigateTo = .feedback
            }) {
                Label("Feedback", systemImage: "square.and.pencil")
            }
            Button(action: {
                navigateTo = .imprint
            }) {
                Label("Imprint", systemImage: "shield")
            }
            Button(action: {
                navigateTo = .about
            }) {
                Label("About Naturblick", systemImage: "info.circle")
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
