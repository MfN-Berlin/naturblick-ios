//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PortraitHeaderView: View {
    let width: CGFloat
    let image: PortraitImage
    let landscape: Bool
    let focus: CGFloat
    @Environment(\.displayScale) private var displayScale: CGFloat
    @State var preview: UIImage? = nil
    @State var full: UIImage? = nil
    @State var showCCByInfo: Bool = false
    
    var body: some View {
        SwiftUI.Group {
            if let full = self.full {
                Image(uiImage: full)
                    .resizable()
                    .scaledToFit()
            } else if let preview = self.preview {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
            } else {
                Spacer()
                    .aspectRatio(image.headerAspectRatio(landscape: landscape), contentMode: .fit)
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
        .clipShape(RoundBottomShape())
        .nbShadow()
        .onAppear {
            let previewUrl = URL(string: Configuration.strapiUrl + image.bestImage(width: width, displayScale: displayScale * .previewScale).url)!
            let fullUrl = URL(string: Configuration.strapiUrl + image.bestImage(width: width, displayScale: displayScale).url)!
            if previewUrl != fullUrl {
                Task {
                    if let uiImage = await URLSession.shared.cachedImage(url: previewUrl) {
                        if image.widerThanFocusPoint(landscape: landscape) {
                            Task.detached { @MainActor in
                                self.preview = uiImage
                            }
                        } else {
                            let crop = uiImage.cropToFocus(landscape: landscape, focus: focus)
                            Task.detached { @MainActor in
                                self.preview = crop
                            }
                        }
                    }
                }
            }
            Task {
                if let uiImage = await URLSession.shared.cachedImage(url: fullUrl) {
                    if image.widerThanFocusPoint(landscape: landscape) {
                        Task.detached { @MainActor in
                            self.full = uiImage
                        }
                    } else {
                        let crop = uiImage.cropToFocus(landscape: landscape, focus: focus)
                        Task.detached { @MainActor in
                            self.full = crop
                        }
                    }
                }
            }
        }
        .sourcesAlert(show: $showCCByInfo, image: image)
    }
}

#Preview {
    PortraitHeaderView(width: 800, image: PortraitImage.sampleData, landscape: true, focus: 0.34)
}
