//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import CachedAsyncImage
import UIKit

class ObservationInfoViewModel: ObservableObject {
        
    @Published var species: SpeciesListItem?
    @Published var created: ZonedDateTime
    @Published var thumbnail: NBImage?
    
    @Published var fullscreenImage: NBImage? = nil
    
    @Published var sound: NBSound? = nil
    @Published var start: Int? = nil
    @Published var end: Int? = nil
    
    @MainActor
    init(editFlowVM: EditFlowViewModel) {
        let data = editFlowVM.data
            
        species = data.species
        created = data.original.created
        
        start = data.original.segmStart.map { s in Int(s) } ?? nil
        end = data.original.segmEnd.map { s in Int(s) } ?? nil

        if data.original.obsType == .audio || data.original.obsType == .unidentifiedaudio {
            if let mediaId = data.original.mediaId {
                sound = NBSound(id: mediaId)
            }
            Task {
                if let thumbnailId = data.original.thumbnailId {
                    thumbnail = try await NBImage(id: thumbnailId)
                }
            }
        } else if (data.original.obsType == .image || data.original.obsType == .unidentifiedimage) {
            Task {
                if let thumbnailId = data.original.thumbnailId {
                    thumbnail = try await NBImage(id: thumbnailId)
                }
            }
            Task {
                if let mediaId = data.original.mediaId {
                    fullscreenImage = try await NBImage(id: mediaId)
                }
            }
        }
    }
    
    init(createFlowVM: CreateFlowViewModel) {
        let data = createFlowVM.data
        species = data.species
        created = data.created
        thumbnail = data.sound.crop ?? data.image.crop
        fullscreenImage = data.image.image
        
        sound = data.sound.sound
        start = data.sound.start
        end = data.sound.end
    }
}
