//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct AsyncThumbnail<Content: View, Placeholder: View> : View {
    let speciesUrl: String?
    let thumbnailId: UUID?
    @State var uiImage: UIImage? = nil
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    init(speciesUrl: String?, thumbnailId: UUID?, @ViewBuilder content: @escaping (Image) -> Content, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.speciesUrl = speciesUrl
        self.thumbnailId = thumbnailId
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        if let uiImage = self.uiImage {
            content(Image(uiImage: uiImage))
        } else {
            placeholder()
                .onAppear {
                    if let thumbnailId = self.thumbnailId {
                        Task {
                            let image = try await BackendClient().downloadCached(mediaId: thumbnailId)
                            self.uiImage = image.image
                        }
                    } else if let speciesUrl = speciesUrl {
                        Task {
                            let uiImage = try await BackendClient().downloadCached(speciesUrl: speciesUrl)
                            self.uiImage = uiImage
                        }
                    }
                }
        }
    }
}

struct AsyncThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        AsyncThumbnail(
            speciesUrl: nil,
            thumbnailId: nil
        ) { image in
            image
        } placeholder: {
            Text("Loading...")
        }
    }
}

