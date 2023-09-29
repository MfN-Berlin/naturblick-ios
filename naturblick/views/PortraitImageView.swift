//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import BottomSheet

struct PortraitImageView: View {
    let geo: GeometryProxy
    let image: PortraitImage
    let headerImage: Bool
    @Environment(\.displayScale) private var displayScale: CGFloat
    @State var preview: UIImage? = nil
    @State var full: UIImage? = nil
    @State var showCCByInfo: Bool = false
    
    @Binding var bottomSheetPosition: BottomSheetPosition
    @Binding var license: PortraitImage?
    
    var body: some View {
        
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
                    license = image
                    bottomSheetPosition = .dynamic
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
    }
}


struct PortraitImageView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            PortraitImageView(geo: geo, image: PortraitImage.sampleData, headerImage: true, bottomSheetPosition: .constant(.hidden), license: .constant(nil))
        }
    }
}
