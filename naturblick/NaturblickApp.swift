//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

enum DeepLink : Equatable {
    case resetPasswort(token: String)
    case speciesPortrait(speciesId: Int64)
    case activateAccount(token: String)
}

@main
struct NaturblickApp: App {
    
    @State var deepLink: DeepLink? = nil
    @StateObject var persistenceController = ObservationPersistenceController()
    
    func navigationBarStyling() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(.primaryColor)
        
        guard let latoBlack19 = UIFont(name: "Lato-Black", size: 19) else {
            fatalError("""
                Failed to load the "Lato-Black" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }

        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(.onPrimaryHighEmphasis),
            .font: latoBlack19
        ]

        appearance.largeTitleTextAttributes = attrs
        appearance.titleTextAttributes = attrs
        
        // In iOS 15, this property applies to all navigation bars. (see https://developer.apple.com/documentation/uikit/uinavigationbar/3198027-scrolledgeappearance)
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView(deeplink: $deepLink)
            }
            .environmentObject(persistenceController)
            .accentColor(.onPrimaryHighEmphasis)
            .font(.nbHeadline6)
            .onOpenURL { url in
                let path: [String] = url.pathComponents
                if (path.count >= 3) {
                    if (path[1] == "species") {
                        if let speciesStr = url.pathComponents.last {
                            let speciesId = Int64(speciesStr)!
                            deepLink = .speciesPortrait(speciesId: speciesId)
                        } else {
                            preconditionFailure("route to artportrait is invalid [\(url.pathComponents)]")
                        }
                    } else if (path[1] == "account") {
                        let second = path[2]
                        if (second == "activate") {
                            if let token = url.pathComponents.last {
                                deepLink = .activateAccount(token: token)
                            }
                        } else if (second == "reset-password") {
                            if let token = url.valueOf("token") {
                                deepLink = .resetPasswort(token: token)
                            }
                        }
                    }
                } else {
                    preconditionFailure("route is invalid [\(url.pathComponents)]")
                }
            }
        }
    }
    
    init() {
        Task {
            do {
                try await BackendClient().register()
            } catch {
                preconditionFailure("could not register device")
            }
        }
        navigationBarStyling()
    }
}
