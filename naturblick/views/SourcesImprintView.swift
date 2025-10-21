//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SourcesImprintView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Further Sources"
    @StateObject var model: SourcesImprintViewModel
    let section: String

    init(section: String) {
        self._model = StateObject(wrappedValue: SourcesImprintViewModel(section: section))
        self.section = section
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text(LocalizedStringKey(section))
                    .headline4()
                ForEach(model.sources) { source in
                    VStack(alignment: .leading) {
                        Text(source.text)
                        if let url = source.imageSource {
                            Link(destination: URL(string: url)!) {
                                Text(url)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }.accessibilityElement(children: .combine)
                }
            }
            .padding(.defaultPadding)
        }
    }
}

