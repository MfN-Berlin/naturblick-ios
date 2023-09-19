//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct Thumbnail<Content: View> : View {
    let speciesUrl: String?
    let thumbnailId: UUID?
    @State var uiImage: UIImage? = nil
    let content: (Image) -> Content

    init(speciesUrl: String?, thumbnailId: UUID?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.speciesUrl = speciesUrl
        self.thumbnailId = thumbnailId
        self.content = content
    }

    var body: some View {
        SwiftUI.Group {
            if let uiImage = self.uiImage {
                content(Image(uiImage: uiImage))
            } else {
                content(Image("placeholder"))
            }
        }
        .task(id: thumbnailId) {
            if let thumbnailId = self.thumbnailId {
                self.uiImage = try? await NBImage(id: thumbnailId).image
            } else if let speciesUrl = speciesUrl {
                self.uiImage = try? await BackendClient().downloadCached(speciesUrl: speciesUrl)
            }
        }
    }
}

struct Thumbnail_Previews: PreviewProvider {
    static var previews: some View {
        Thumbnail(
            speciesUrl: nil,
            thumbnailId: nil
        ) { image in
            image
        }
    }
}

