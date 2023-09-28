//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import CachedAsyncImage
import UIKit

class ObservationInfoViewModel: ObservableObject {
        
    @Published var thumbnail: NBImage? = nil
    @Published var fullscreenImage: NBImage? = nil
    
    let species: SpeciesListItem?
    let created: ZonedDateTime
    
    let sound: NBSound?
    let start: Int?
    let end: Int?
    
    @MainActor
    init(data: EditData) {
        species = data.species
        created = data.original.created
        
        start = data.original.segmStart.map { s in Int(s) } ?? nil
        end = data.original.segmEnd.map { s in Int(s) } ?? nil

        if (data.original.obsType == .audio || data.original.obsType == .unidentifiedaudio) {
            sound = NBSound(id: data.original.mediaId!)
        } else {
            sound = nil
        }
        Task {
            if let thumbnailId = data.original.thumbnailId {
                thumbnail = try await NBImage(id: thumbnailId)
            }
        }
        
        if (data.original.obsType == .image || data.original.obsType == .unidentifiedimage) {
            Task {
                if let mediaId = data.original.mediaId {
                    fullscreenImage = try await NBImage(id: mediaId)
                }
            }
        }
    }
    
    init(data: CreateData) {
        species = data.species
        created = data.created
        thumbnail = data.sound.crop ?? data.image.crop
        fullscreenImage = data.image.image
        
        sound = data.sound.sound
        start = data.sound.start
        end = data.sound.end
    }
}
