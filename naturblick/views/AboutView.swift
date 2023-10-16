//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct AboutView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "about")
    
    func configureNavigationItem(item: UINavigationItem) {
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text("about_text")
                    .body1()
                Button("feedback_form") {
                    let deviceName = "ios"
                    let appVersion = UIApplication.appVersion
                    let survey = "https://survey.naturkundemuseum-berlin.de/de/Feedback%20Naturblick?device_name=\(deviceName)&version=\(appVersion)"
                    if let url = URL(string: survey) {
                        UIApplication.shared.open(url)
                    }
                }.buttonStyle(ConfirmFullWidthButton())
                
                Button("feedback_email") {
                    let email = "naturblick@mfn-berlin.de"
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }.buttonStyle(ConfirmFullWidthButton())
            }
        }
        .padding(.defaultPadding)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
