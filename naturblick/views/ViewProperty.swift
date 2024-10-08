//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ViewProperty: View {
    let icon: String
    let label: String
    let content: String?
    var body: some View {
        HStack {
            Image(decorative: icon)
                .observationProperty()
            VStack(alignment: .leading, spacing: .zero) {
                Text(label)
                    .caption(color: .onSecondarySignalLow)
                if let text = content, !text.isEmpty {
                    Text(text)
                        .body1()
                } else {
                    Text(" ")
                        .body1()
                }
            }
        }
    }
}

struct ViewProperty_Previews: PreviewProvider {
    static var previews: some View {
        ViewProperty(icon: "placeholder", label: "Label", content: "Test")
    }
}
