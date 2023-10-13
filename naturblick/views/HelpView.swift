//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct HelpView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Help"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text("help_text")
                    .body1()
            }
        }
        .padding(.defaultPadding)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
