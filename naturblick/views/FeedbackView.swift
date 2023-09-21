//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct FeedbackView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Feedback"
    
    func configureNavigationItem(item: UINavigationItem) {
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("**Support us!**\n\nNaturblick is continuously being further developed in terms of content and technology. We depend on your feedback. Suggest changes, improvements, or report bugs.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                Button {
                    let deviceName = "ios"
                    let appVersion = UIApplication.appVersion
                    let survey = "https://survey.naturkundemuseum-berlin.de/de/Feedback%20Naturblick?device_name=\(deviceName)&version=\(appVersion)"
                    if let url = URL(string: survey) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Use our feedback form")
                        .button()
                        .padding()
                }.background(Color.onSecondaryButtonPrimary)
                    .padding()
                Button {
                    let email = "naturblick@mfn-berlin.de"
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Send an email")
                        .button()
                        .padding()
                }.background(Color.onSecondaryButtonPrimary)
                    .padding()
            }
        }.foregroundColor(.onSecondaryHighEmphasis)
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
