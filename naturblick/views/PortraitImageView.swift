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
    
    var body: some View {
        ZStack {
            VStack {
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
                        Image("placeholder")
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(headerImage ? 0.0 : .smallCornerRadius)
                    }
                }
         .overlay(alignment: .topTrailing) {
                    Button(action: {
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
                        .font(.nbBody1)
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
            if (showCCByInfo) {
                CCInfoPopupView(present: $showCCByInfo, imageSource: image.source, imageOwner: image.owner, imageLicense: image.license)
            }
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
