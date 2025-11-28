//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import QuickLook

struct ObservationInfoView: View {
    let backend: Backend
    let width: CGFloat
    let present: (UIViewController) -> Void

    let species: SpeciesListItem?
    let created: ZonedDateTime
    
    let start: Int?
    let end: Int?
    let thumbnailId: UUID?
    let fallbackThumbnail: Image
    let obsType: ObsType
    let obsIdent: String?
    @StateObject var model: ObservationInfoViewModel
    @State var thumbnail: Image? = nil
    let sound: NBSound?
    
    init(backend: Backend, width: CGFloat, fallbackThumbnail: Image, observation: Observation, sound: NBSound?, present: @escaping (UIViewController) -> Void) {
        self.backend = backend
        self.obsIdent = observation.observation.obsIdent
        self.obsType = observation.observation.obsType
        self.sound = sound
        self.width = width
        self.present = present
        self.species = observation.species?.listItem
        self.created = observation.observation.created
        self.start = observation.observation.segmStart.map { s in Int(s) } ?? nil
        self.end = observation.observation.segmEnd.map { s in Int(s) } ?? nil
        
        if observation.observation.obsType == .image || observation.observation.obsType == .unidentifiedimage, let mediaId = observation.observation.mediaId {
            _model = StateObject(wrappedValue:
                ObservationInfoViewModel(mediaId: mediaId, localIdentifier: observation.observation.localMediaId, backend: backend)
            )
        } else {
            _model = StateObject(wrappedValue:
                ObservationInfoViewModel(mediaId: nil, localIdentifier: nil, backend: backend)
            )
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
                .accessibilityHidden(true)
        } else {
            return fallbackThumbnail
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: width * 0.4, height: width * 0.4)
                .accessibilityHidden(true)
        }
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            if model.mediaId != nil {
                avatar
                    .overlay(alignment: .bottomTrailing) {
                        ZStack {
                            if(model.loadingImage) {
                                FABView(systemName: "clock.circle", color: .onSecondaryButtonSecondary, size: .mini)
                            } else {
                                FABView("zoom", color: .onSecondaryButtonSecondary, size: .mini)
                            }
                        }.onTapGesture {
                            Task { @MainActor in
                                do {
                                    try await model.downloadImageItem()
                                    let controller = QLPreviewController()
                                    controller.dataSource = model
                                    present(controller)
                                } catch {
                                    model.handle(error)
                                }
                            }
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
                    if let gender = species.gender {
                        Text(gender)
                            .foregroundColor(.onPrimaryHighEmphasis)
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
        .alertHttpError(isPresented: $model.isPresented, error: model.error)
        .task(id: thumbnailId) {
            if let id = thumbnailId, let image = try? await backend.downloadCached(mediaId: id) {
                thumbnail = Image(uiImage: image)
            }
        }

    }
}
