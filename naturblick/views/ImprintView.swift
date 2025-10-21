//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ImprintView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "imprint")
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text("imprint_1 \(UIApplication.appVersion)")
                    .body1()
                Button("more_sources") {
                    navigationController?.pushViewController(SourcesImprintsView().setUpViewController(), animated: true)
                }.buttonStyle(ConfirmFullWidthButton())
                Text("imprint_2")
                    .body1()
            }
        }
        .padding(.defaultPadding)
    }
}

struct ImprintView_Previews: PreviewProvider {
    static var previews: some View {
        ImprintView()
    }
}
