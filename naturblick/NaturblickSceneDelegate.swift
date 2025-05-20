//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import UIKit
import SQLite

enum DeepLink : Equatable {
    case resetPasswort(token: String)
    case speciesPortrait(speciesId: Int64)
    case activateAccount(token: String)
}

class NaturblickSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            handle(userActivity, windowScene)
        } else {
            startScene(windowScene: windowScene)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let windowScene = scene as? UIWindowScene,
        userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return
        }
        handle(userActivity, windowScene)
    }
    
    
    private func handle(_ userActivity: NSUserActivity, _ windowScene: UIWindowScene) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let pathComponents = userActivity.webpageURL?.pathComponents,
              let nsURLComponents = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else { return }
        
        if (pathComponents.count >= 3) {
            if (pathComponents[1] == "species") {
                if let speciesStr = pathComponents.last, let speciesId = Int64(speciesStr) {
                    startScene(windowScene: windowScene, deepLink: .speciesPortrait(speciesId: speciesId))
                } else {
                    return
                }
            } else if (pathComponents[1] == "account") {
                let second = pathComponents[2]
                if (second == "activate") {
                    if let token = pathComponents.last {
                        startScene(windowScene: windowScene, deepLink: .activateAccount(token: token))
                    }
                } else if (second == "reset-password") {
                    if let token = nsURLComponents.queryItems?.first(where: { $0.name == "token" })?.value {
                        startScene(windowScene: windowScene, deepLink: .resetPasswort(token: token))
                    }
                }
            }
        } else {
            return
        }
    }
    
    private func startScene(windowScene: UIWindowScene, deepLink: DeepLink? = nil) {
        Keychain.shared.refresh()
        let existingCcByName = UserDefaults.standard.string(forKey: "ccByName")
        let existingAgb = UserDefaults.standard.bool(forKey: "agb")
        let existingAccountInfo = UserDefaults.standard.bool(forKey: "accountInfo")
        if existingCcByName == nil || !existingAgb || !existingAccountInfo {
            if let userData = OldUserData.getFromOldDB() {
                if let ccByName = userData.name, existingCcByName == nil {
                    UserDefaults.standard.setValue(ccByName, forKey: "ccByName")
                    UserDefaults.standard.setValue(true, forKey: "ccByNameWasSet")
                }
                if let agb = userData.policy, !existingAgb {
                    UserDefaults.standard.setValue(agb, forKey: "agb")
                }
                if let accountInfo = userData.accountFeatShown, !existingAccountInfo {
                    UserDefaults.standard.setValue(accountInfo, forKey: "accountInfo")
                }
            }
        }

        URLSession.shared.configuration.timeoutIntervalForRequest = 15
        URLSession.shared.configuration.timeoutIntervalForResource = 30
        
        let backend = Backend(persistence: ObservationPersistenceController())
        
        Task {
            try? await backend.register()
        }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = PopAwareNavigationController(rootViewController: HomeViewController(backend: backend))
        
        switch deepLink {
        case .activateAccount(let token):
            navigationController.pushViewController(AccountView(backend: backend, token: token).setUpViewController(), animated: true)
        case .resetPasswort(let token):
            navigationController.pushViewController(ResetPasswordView(backend: backend, token: token).setUpViewController(), animated: true)
        case .speciesPortrait(let speciesId):
            let speciesDb: Connection = Connection.speciesDB
            if let row = try? speciesDb.pluck(Species.Definition.table.join(.leftOuter, Species.Definition.tableAlias, on: Species.Definition.table[Species.Definition.accepted] == Species.Definition.tableAlias[Species.Definition.id]).filter(Species.Definition.table[Species.Definition.id] == speciesId)) {
                let realSpeciesId = Species.acceptedSpeciesId(row: row)
                let portraits = try? speciesDb.scalar(
                    Portrait.Definition.table
                        .filter(Portrait.Definition.speciesId == realSpeciesId)
                        .filter(Portrait.Definition.language == Int(getLanguageId()))
                        .count
                )
                let species = Species.acceptedFromRow(row: row, hasPortraits: (portraits ?? 0) > 0)
                navigationController.pushViewController(SpeciesInfoView(selectionFlow: false, species: species.listItem, flow: VoidSelectionFlow()).setUpViewController(), animated: true)
            }
        default: break
        }
            
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

}
