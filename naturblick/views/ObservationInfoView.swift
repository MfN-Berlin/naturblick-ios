//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationInfoView: View {
    let client = BackendClient()
    let width: CGFloat
    let navigate: (UIViewController) -> Void

    let species: SpeciesListItem?
    let created: ZonedDateTime
    
    let sound: NBSound?
    let start: Int?
    let end: Int?
    let fullscreenImageId: UUID?
    let thumbnailId: UUID?
    let fallbackThumbnail: Image
    @State var thumbnail: Image? = nil
    
    init(width: CGFloat, fallbackThumbnail: Image, observation: Observation, navigate: @escaping (UIViewController) -> Void) {
        self.width = width
        self.navigate = navigate
        self.species = observation.species?.listItem
        self.created = observation.observation.created
        self.start = observation.observation.segmStart.map { s in Int(s) } ?? nil
        self.end = observation.observation.segmEnd.map { s in Int(s) } ?? nil
        if observation.observation.obsType == .audio || observation.observation.obsType == .unidentifiedaudio,  let mediaId = observation.observation.mediaId {
            self.sound = NBSound(id: mediaId)
        } else {
            self.sound = nil
        }
        
        if observation.observation.obsType == .image || observation.observation.obsType == .unidentifiedimage, let mediaId = observation.observation.mediaId {
            self.fullscreenImageId = mediaId
        } else {
            self.fullscreenImageId = nil
        }
        self.thumbnailId = observation.observation.thumbnailId
        self.fallbackThumbnail = fallbackThumbnail
    }
    
    var avatar: some View {
        if let thumbnail = thumbnail {
            return thumbnail
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: width * 0.4, height: width * 0.4)
        } else {
            return fallbackThumbnail
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: width * 0.4, height: width * 0.4)
        }
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            if let fullscreenImageId = fullscreenImageId {
                avatar
                    .overlay(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.onPrimaryButtonPrimary)
                                .frame(width: 40, height: 40)
                            Image("zoom")
                                .foregroundColor(.onPrimaryHighEmphasis)
                        }.onTapGesture {
                            navigate(FullscreenView(imageId: fullscreenImageId).setUpViewController())
                        }
                    }
                    .padding(.bottom, .defaultPadding)
            } else if let sound = sound {
                avatar
                    .overlay(alignment: .bottomTrailing) {
                        SoundButton(url: sound.url)
                    }
                    .padding(.bottom, .defaultPadding)
            } else {
                avatar
                    .padding(.bottom, .defaultPadding)
            }
            if let sciname = species?.sciname {
                Text(sciname)
                    .overline(color: .onPrimarySignalHigh)
                    .multilineTextAlignment(TextAlignment.center)
            }
            Text(species?.name ?? "unknown_species")
                .headline2()
                .multilineTextAlignment(TextAlignment.center)
            Text(created.date, formatter: .dateTime)
                .caption(color: .onPrimarySignalLow)
                .multilineTextAlignment(TextAlignment.center)
        }
        .padding(.defaultPadding)
        .background(Color(uiColor: .onPrimaryButtonSecondary))
        .task(id: thumbnailId) {
            if let id = thumbnailId, let image = try? await client.download(mediaId: id) {
                thumbnail = Image(uiImage: image)
            }
        }
    }
}
