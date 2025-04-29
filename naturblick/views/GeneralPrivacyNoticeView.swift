//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct GeneralPrivacyNoticeView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "privacy_notice")
    
    func configureNavigationItem(item: UINavigationItem) {
    }
    
    var body: some View {
        ScrollView {
            Text("TBD")
                .body1()
        }
        .padding(.defaultPadding)
    }
}

struct GeneralPrivacyNoticeView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPrivacyNoticeView()
    }
}
