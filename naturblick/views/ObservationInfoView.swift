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
    
    let start: Int?
    let end: Int?
    let fullscreenImageId: UUID?
    let fullscreenLocalId: String?
    let thumbnailId: UUID?
    let fallbackThumbnail: Image
    let obsType: ObsType
    let obsIdent: String?
    @State var thumbnail: Image? = nil
    let sound: NBSound?
    
    init(width: CGFloat, fallbackThumbnail: Image, observation: Observation, sound: NBSound?, navigate: @escaping (UIViewController) -> Void) {
        self.obsIdent = observation.observation.obsIdent
        self.obsType = observation.observation.obsType
        self.sound = sound
        self.width = width
        self.navigate = navigate
        self.species = observation.species?.listItem
        self.created = observation.observation.created
        self.start = observation.observation.segmStart.map { s in Int(s) } ?? nil
        self.end = observation.observation.segmEnd.map { s in Int(s) } ?? nil
        
        if observation.observation.obsType == .image || observation.observation.obsType == .unidentifiedimage, let mediaId = observation.observation.mediaId {
            self.fullscreenImageId = mediaId
            self.fullscreenLocalId = observation.observation.localMediaId
        } else {
            self.fullscreenImageId = nil
            self.fullscreenLocalId = nil
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
                            navigate(FullscreenView(imageId: fullscreenImageId, localIdentifier: self.fullscreenLocalId).setUpViewController())
                        }
                    }
                    .padding(.bottom, .defaultPadding)
            } else if let sound = sound {
                avatar
                    .overlay(alignment: .bottomTrailing) {
                        SoundButton(sound: sound)
                    }
                    .padding(.bottom, .defaultPadding)
            } else {
                avatar
                    .padding(.bottom, .defaultPadding)
            }

            if let species = species {
                if let name = species.speciesName {
                    Text(species.sciname)
                        .overline(color: .onPrimarySignalHigh)
                        .multilineTextAlignment(TextAlignment.center)
                    Text(name.uppercased())
                        .headline2()
                        .multilineTextAlignment(TextAlignment.center)
                    if let isFemale = species.isFemale {
                        if isFemale {
                            Image("female")
                        } else {
                            Image("male")
                        }
                    }
                } else {
                    Text(species.sciname.uppercased())
                        .headline2()
                        .multilineTextAlignment(TextAlignment.center)
                }
            } else {
                Text((String(localized: "unknown_species")).uppercased())
                    .headline2()
                    .multilineTextAlignment(TextAlignment.center)
            }
            Text(created.date, formatter: .dateTime)
                .caption(color: .onPrimarySignalLow)
                .multilineTextAlignment(TextAlignment.center)
        }
        .padding(.defaultPadding)
        .background(Color(uiColor: .onPrimaryButtonSecondary))
        .task(id: thumbnailId) {
            if let id = thumbnailId, let image = try? await client.downloadCached(mediaId: id) {
                thumbnail = Image(uiImage: image)
            }
        }
    }
}
