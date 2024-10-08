//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class SettingsViewController: HostingController<SettingsView> {
    init() {
        super.init(rootView: SettingsView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(true, forKey: "ccByNameWasSet")
    }
}

struct SettingsView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "settings")
    
    @AppStorage("ccByName") var ccByName: String = "MfN Naturblick"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text("cc_by_msg")
                    .body1()
                
                HStack {
                    Image(decorative: "create_24px")
                        .observationProperty()
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: .zero) {
                        Text("cc_by_field")
                            .caption(color: .onSecondarySignalLow)
                        TextField(String(localized: "cc_by_field"), text: $ccByName)
                    }
                }
            }
        }.padding(.defaultPadding)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
