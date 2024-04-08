//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SourcesImprintView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Further Sources"
    @StateObject var model = SourcesImprintViewModel()
    

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                ForEach(model.sources) { source in
                    VStack(alignment: .leading) {
                        Text(source.text)
                        if let url = source.imageSource {
                            Link(destination: URL(string: url)!) {
                                Text(url)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
            }
            .padding(.defaultPadding)
        }
    }
}

