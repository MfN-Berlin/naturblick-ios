//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct Thumbnail<Content: View> : View {
    let occurenceId: UUID
    let persistenceController: ObservationPersistenceController
    let speciesUrl: String?
    let thumbnailId: UUID?
    let obsIdent: String?
    @State var uiImage: UIImage? = nil
    let content: (Image) -> Content

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
                if let thumbnail = try? await NBThumbnail(id: thumbnailId).image {
                    self.uiImage = thumbnail
                } else {
                    self.uiImage = NBThumbnail.findLocal(occurenceId: occurenceId, obsIdent: obsIdent)
                }
            } else if let obsIdent = obsIdent, let thumbnail = NBThumbnail.loadOld(occurenceId: occurenceId, obsIdent: obsIdent, persistenceController: persistenceController) {
                self.uiImage = thumbnail.image
            } else if let speciesUrl = speciesUrl {
                self.uiImage = await URLSession.shared.cachedImage(url: URL(string: Configuration.strapiUrl + speciesUrl)!)
            }
        }
    }
}

struct Thumbnail_Previews: PreviewProvider {
    static var previews: some View {
        Thumbnail(
            occurenceId: UUID(),
            persistenceController: ObservationPersistenceController(inMemory: true),
            speciesUrl: nil,
            thumbnailId: nil,
            obsIdent: nil
        ) { image in
            image
        }
    }
}

