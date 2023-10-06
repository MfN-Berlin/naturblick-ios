//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import UIKit

class NaturblickSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        UINavigationBar.appearance().tintColor = .onPrimaryHighEmphasis

        let window = UIWindow(windowScene: windowScene)
        let navigationController = PopAwareNavigationController(rootViewController: HomeViewController())
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}
