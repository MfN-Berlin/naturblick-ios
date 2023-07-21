//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SettingsView: View {
    
    @AppStorage("ccByName") var ccByName: String = "MfN Naturblick"
    
    var body: some View {
        BaseView {
            ScrollView {
                VStack {
                    Text("**Authorship**\n\nAll recordings made with Naturblick are licensed under CC BY-SA 4.0, i.e. they may be distributed and used.\n\nIf you want, you can attribute your authorship with a name. The material will then be published together with this name. All footage that has not been assigned an author name will be published under MfN_Naturblick.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    NBEditText(label: "Name (Synonym)", icon: Image(systemName: "pencil"), text: $ccByName)
                    
                    // speichern button
                    Text("**Information about linked devices**\n\nThis is the list of devices that were used with Naturblick.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    Text("TODO johannes")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
