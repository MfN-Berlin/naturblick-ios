//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct MenuView: View {
    let navigationController: UINavigationController
    
    var body: some View {
        Menu {
            Button(action: {
                let helpViewController = HelpView().setUpViewController()
                navigationController.pushViewController(helpViewController, animated: true)
            }) {
                Label("Help", systemImage: "questionmark.circle")
            }
            Button(action: {
                let accountViewController = AccountView().setUpViewController()
                navigationController.pushViewController(accountViewController, animated: true)
            }) {
                Label("Account", systemImage: "person")
            }
            Button(action: {
                let settingViewController = SettingsView().setUpViewController()
                navigationController.pushViewController(settingViewController, animated: true)
            }) {
                Label("Settings", systemImage: "gearshape")
            }
            Button(action: {
                print("Here comes the feedback-view")
            }) {
                Label("Feedback", systemImage: "square.and.pencil")
            }
            Button(action: {
                let imprintViewController = ImprintView().setUpViewController()
                navigationController.pushViewController(imprintViewController, animated: true)
            }) {
                Label("Imprint", systemImage: "shield")
            }
            Button(action: {
                let aboutViewController = AboutView().setUpViewController()
                navigationController.pushViewController(aboutViewController, animated: true)
            }) {
                Label("About Naturblick", systemImage: "info.circle")
            }
            
        } label: {
            Image(systemName: "gearshape")
                .foregroundColor(.onPrimaryHighEmphasis)
        }
    }
}

