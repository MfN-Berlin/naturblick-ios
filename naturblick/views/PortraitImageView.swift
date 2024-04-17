//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PortraitImageView: View {
    let geo: GeometryProxy
    let image: PortraitImage
    let headerImage: Bool
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
                            .cornerRadius(headerImage ? 0.0 : .smallCornerRadius)
                    } else if let preview = self.preview {
                        Image(uiImage: preview)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(headerImage ? 0.0 : .smallCornerRadius)
                    } else {
                        Spacer()
                            .aspectRatio(aspectRatio, contentMode: .fit)
                            .cornerRadius(headerImage ? 0.0 : .smallCornerRadius)
                    }
                }
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
                }
                if !headerImage {
                    Text(image.text)
                        .body1()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.onAppear {
                let previewUrl = URL(string: Configuration.strapiUrl + image.bestImage(geo: geo, displayScale: displayScale * .previewScale).url)!
                let fullUrl = URL(string: Configuration.strapiUrl + image.bestImage(geo: geo, displayScale: displayScale).url)!
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
                            self.preview = image
                        }
                    }
                }
            }
            .alert("source",
                   isPresented: $showCCByInfo,
                   actions: { 
                Link("to_orig", destination: URL(string: image.source)!)
                Link("to_licence", destination: URL(string: Licence.licenceToLink(licence: image.license))!)
                        Button("close") { showCCByInfo = false } },
                   message: { Text("(\(image.license)) \(image.owner)") } )
        }
    }
}

struct PortraitImageView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            PortraitImageView(geo: geo, image: PortraitImage.sampleData, headerImage: true)
        }
    }
}
