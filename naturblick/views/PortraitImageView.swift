//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct PortraitImageView: View {
    @StateObject var portraitImageViewModel = PortraitImageViewModel()
    let meta: PortraitImageMeta
    
    var body: some View {
        VStack {
            if let item = portraitImageViewModel.image {
                AsyncImage(url: URL(string: Configuration.strapiUrl + item.url)!) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image("placeholder")
                }
                HStack {
                    Text(meta.text)
                    Text(meta.owner)
                    Text(meta.license)
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
        PortraitImageView(meta: PortraitImageMeta.sampleData)
    }
}
