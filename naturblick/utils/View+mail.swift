//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

extension View {

    func canOpenEmail() -> Bool {
        UIApplication.shared.canOpenURL(URL(string: "message://")!)
    }
    
    func openMail(completionHandler completion: ((Bool) -> Void)? = nil) {
        let url = URL(string: "message://")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
        }
    }
}
