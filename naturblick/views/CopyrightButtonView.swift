//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct CopyrightButtonView: View {
    let source: String
    let license: String
    let owner: String
    let ownerLink: String?
    @State var showCCByInfo: Bool = false
    var body: some View {
        SwiftUI.Button(action: {
            showCCByInfo.toggle()
        }) {
            Circle()
                .fill(Color.onImageSignalLow)
                .overlay {
                    Image("ic_copyright")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.onPrimaryHighEmphasis)
                        .padding(.fabIconMicroPadding)
                }
                .frame(width: .fabMicroSize, height: .fabMicroSize)
        }
        .accessibilityLabel(Text("Copyright"))
        .alert("source", isPresented: $showCCByInfo) {
            if let url = URL(string: source) {
                Link("to_orig", destination: url)
            }
            if let url = URL(string: Licence.licenceToLink(licence: license)) {
                Link("to_licence", destination: url)
            }
            if let link = ownerLink, !link.isEmpty,
               let url = URL(string: link) {
                Link("to_owner_page", destination: url)
            }
            Button("close") { $showCCByInfo.wrappedValue = false }
        } message: {
            Text("\(owner) / CC BY")
        }
    }
}
