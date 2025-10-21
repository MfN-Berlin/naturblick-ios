//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SourcesImprintsView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Further Sources"

    let sections = ["ident_keys","sound_recogniotion_images", "sound_recogniotion_sounds"]

    var body: some View {
        VStack {
            List(sections, id: \.self) { section in
                HStack {
                    Text(LocalizedStringKey(section))
                        .subtitle1()
                    Spacer()
                    ChevronView()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    navigationController?.pushViewController(SourcesImprintView(section: section).setUpViewController(), animated: true)
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(Color.secondaryColor)
            }
            .listStyle(.plain)
            .foregroundColor(.onPrimaryHighEmphasis)
        }
    }
}
