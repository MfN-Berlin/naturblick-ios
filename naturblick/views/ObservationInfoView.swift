//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationInfoView: View {
    let width: CGFloat
    let navigate: (UIViewController) -> Void

    let species: SpeciesListItem?
    let created: ZonedDateTime
    
    let sound: NBSound?
    let start: Int?
    let end: Int?
    let fullscreenImageId: UUID?
    let thumbnail: Image
    
    init(width: CGFloat, fallbackThumbnail: Image, data: EditData, navigate: @escaping (UIViewController) -> Void) {
        self.width = width
        self.navigate = navigate
        self.species = data.species
        self.created = data.original.created
        self.start = data.original.segmStart.map { s in Int(s) } ?? nil
        self.end = data.original.segmEnd.map { s in Int(s) } ?? nil
        if let thumbnail = data.thumbnail?.image {
            self.thumbnail = Image(uiImage: thumbnail)
        } else {
            self.thumbnail = fallbackThumbnail
        }
        if data.original.obsType == .audio || data.original.obsType == .unidentifiedaudio,  let mediaId = data.original.mediaId {
            self.sound = NBSound(id: mediaId)
        } else {
            self.sound = nil
        }
        
        if data.original.obsType == .image || data.original.obsType == .unidentifiedimage, let mediaId = data.original.mediaId {
            self.fullscreenImageId = mediaId
        } else {
            self.fullscreenImageId = nil
        }
    }
    
    init(width: CGFloat, fallbackThumbnail: Image, data: CreateData, navigate: @escaping (UIViewController) -> Void) {
        self.width = width
        self.navigate = navigate
        self.species = data.species
        self.created = data.created
        self.sound = data.sound.sound
        self.start = data.sound.start
        self.end = data.sound.end
        if let thumbnail = data.sound.crop?.image ?? data.image.crop?.image {
            self.thumbnail = Image(uiImage: thumbnail)
        } else {
            self.thumbnail = fallbackThumbnail
        }
        self.fullscreenImageId = data.image.image?.id
    }
    
    
    var avatar: some View {
        thumbnail
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: width * 0.4, height: width * 0.4)
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
                    .font(.nbOverline)
                    .foregroundColor(.onPrimarySignalHigh)
                    .multilineTextAlignment(TextAlignment.center)
            }
            Text(species?.name ?? "Unknown species")
                .font(.nbHeadline2)
                .foregroundColor(.onPrimaryHighEmphasis)
                .multilineTextAlignment(TextAlignment.center)
            Text(created.date, formatter: .dateTime)
                .font(.caption)
                .foregroundColor(.onPrimarySignalLow)
                .multilineTextAlignment(TextAlignment.center)
        }
        .padding(.defaultPadding)
        .background(Color(uiColor: .onPrimaryButtonSecondary))
    }
}
