//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PortraitImageView: View {
    @StateObject var portraitImageViewModel = PortraitImageViewModel()
    let meta: PortraitImageMeta
    let showText: Bool
    
    var body: some View {
        VStack {
            if let item = portraitImageViewModel.image {
                
                ZStack {
                    AsyncImage(url: URL(string: Configuration.strapiUrl + item.url)!) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(showText ? .smallCornerRadius : 0.0)
                    } placeholder: {
                        Image("placeholder")
                    }
                    Button(action: {
                        print("[Source](\(meta.source)) \(Licence.licenceToLink(licence: meta.license)) \(meta.owner)")
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
                            .frame(height: .fabMiniSize)
                            .padding([.top, .horizontal], .defaultPadding)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                }
                if showText {
                    Text(meta.text)
                        .font(.nbBody1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                Text("No Image available")
            }
        }
        .task {
            portraitImageViewModel.filter(portraitImgId: meta.id)
        }
    }
}

struct PortraitImageView_Previews: PreviewProvider {
    static var previews: some View {
        PortraitImageView(meta: PortraitImageMeta.sampleData, showText: true)
    }
}
