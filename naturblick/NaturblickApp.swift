//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

@main
struct NaturblickApp: App {
    
    func navigationBarStyling() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(.primaryColor)
               
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(.onPrimaryHighEmphasis),
            .font: UIFont.systemFont(ofSize: 19)
        ]

        appearance.largeTitleTextAttributes = attrs
        appearance.titleTextAttributes = attrs
        
        // In iOS 15, this property applies to all navigation bars. (see https://developer.apple.com/documentation/uikit/uinavigationbar/3198027-scrolledgeappearance)
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .accentColor(.onPrimaryHighEmphasis)
            .font(.nbHeadline6)
            .environment(\.managedObjectContext, ObservationPersistenceController.shared.container.viewContext)
        }
    }
    
    init() {
        navigationBarStyling()
    }
}
