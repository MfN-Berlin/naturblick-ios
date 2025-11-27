//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

extension View {
    func sourcesAlert(show: Binding<Bool>, image: PortraitImage) -> some View {
        return self.alert("source",
               isPresented: show,
               actions: {
            if let url = URL(string: image.source) {
                Link("to_orig", destination: url)
            }
            if let url = URL(string: Licence.licenceToLink(licence: image.license)) {
                Link("to_licence", destination: url)
            }
            if let ownerLink = image.ownerLink, !ownerLink.isEmpty,
               let url = URL(string: ownerLink) {
                Link("to_owner_page", destination: url)
            }
            Button("close") { show.wrappedValue = false } },
               message: { Text("\(image.owner)/ CC BY") } )
    }
}

struct PortraitImageView: View {
    let width: CGFloat
    let image: PortraitImage
    @Environment(\.displayScale) private var displayScale: CGFloat
    @State var preview: UIImage? = nil
    @State var full: UIImage? = nil
    @State var showCCByInfo: Bool = false
    
    var aspectRatio: CGFloat {
        let size = image.sizes.first!
        return CGFloat(size.width) / CGFloat(size.height)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                SwiftUI.Group {
                    if let full = self.full {
                        Image(uiImage: full)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(.smallCornerRadius)
                    } else if let preview = self.preview {
                        Image(uiImage: preview)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(.smallCornerRadius)
                    } else {
                        Spacer()
                            .aspectRatio(aspectRatio, contentMode: .fit)
                            .cornerRadius(.smallCornerRadius)
                    }
                }
                .accessibilityHidden(true)
                .overlay(alignment: .topTrailing) {
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
                                    .padding(.fabIconMiniPadding)
                            }
                            .frame(width: .fabMiniSize, height: .fabMiniSize)
                            .padding(.defaultPadding)
                    }
                    .accessibilityLabel(Text("Copyright"))
                }
                Text(image.text)
                    .body1()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }.onAppear {
                let previewUrl = URL(string: Configuration.djangoUrl + image.bestImage(width: width, displayScale: displayScale * .previewScale).url)!
                let fullUrl = URL(string: Configuration.djangoUrl + image.bestImage(width: width, displayScale: displayScale).url)!
                if previewUrl != fullUrl {
                    Task {
                        if let image = await URLSession.shared.cachedImage(url: previewUrl) {
                            Task.detached { @MainActor in
                                self.preview = image
                            }
                        }
                    }
                }
                Task {
                    if let image = await URLSession.shared.cachedImage(url: fullUrl) {
                        Task.detached { @MainActor in
                            self.full = image
                        }
                    }
                }
            }
            .sourcesAlert(show: $showCCByInfo, image: image)
        }
    }
}

struct PortraitImageView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            PortraitImageView(width: geo.size.width, image: PortraitImage.sampleData)
        }
    }
}
