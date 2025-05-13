//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct AccessibilityView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "accessibility")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text("accessibility")
                    .subtitle1()
                Text("accessibility_timestamp")
                    .body1()
                Text("accessibility_statement")
                    .body1()
                Text("accessibility_report_problem")
                    .body1()
                Button("accessibility_email") {
                    if let url = URL.accessibilityFeedback() {
                        UIApplication.shared.open(url)
                    }
                }.buttonStyle(ConfirmFullWidthButton())
                Text("accessibility_complete_report")
                    .body1()
                Text("accessibility_german_sign_language")
                    .subtitle1()
                Text("accessibility_german_sign_language_info")
                    .body1()
            }
        }
        .padding(.defaultPadding)
    }
}

struct AccessibilityView_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityView()
    }
}
