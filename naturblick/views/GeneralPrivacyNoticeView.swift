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
            VStack(alignment: .leading) {
                Text("privacy_notice")
                    .headline2()
                Text("privacy_notice_intro")
                    .subtitle1()
                Text("privacy_notice_intro_text")
                    .body2()
                Text("privacy_notice_responsible")
                    .subtitle1()
                Text("privacy_notice_responsible_text")
                    .body2()
                Text("privacy_notice_use")
                    .subtitle1()
                Text("privacy_notice_use_text")
                    .body2()
            }
        }
        .padding(.defaultPadding)
    }
}

struct GeneralPrivacyNoticeView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPrivacyNoticeView()
    }
}
