//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI
import MapKit
import Mantis
import Combine

class EditFlowViewModel: NSObject, CropViewControllerDelegate, IdFlow, PickerFlow, HoldingViewController {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let backend: Backend
    @Published private(set) var result: [SpeciesResult]? = nil
    @Published var data: EditData
    @Published var imageData: ImageData = ImageData()
    @Published var soundData: SoundData = SoundData()
    @Published var speciesAvatar: Image = Image("placeholder")
    @Published var region: MKCoordinateRegion
    var isCreate: Bool = false
    var obsIdent: String? {
        data.original.obsIdent
    }
    init(backend: Backend, observation: Observation) {
        self.backend = backend
        let data = EditData(observation: observation)
        self.data = data
        self.region = data.region
        super.init()
        
        Publishers.Merge(
            $imageData.map { data in
                data.result
            },
            $soundData.map { data in
                data.result
            }
        )
        .assign(to: &$result)
        
        if let thumbnailId = observation.observation.thumbnailId {
            Task {
                let thumbnail = try await NBThumbnail(id: thumbnailId, backend: backend)
                await setThumbnail(thumbnail: thumbnail)
            }
        }
        
        if let speciesUrl = data.species?.url {
            Task {
                await setSpeciesAvatar(avatar: await URLSession.shared.cachedImage(url: URL(string: Configuration.djangoUrl + speciesUrl)!))
            }
        }
    }
    
    @MainActor private func setThumbnail(thumbnail: NBThumbnail) async {
        data.thumbnail = thumbnail
    }

    @MainActor func cropPhoto(image: NBImage) {
        imageData.image = image
        imageData.crop = nil
        var config = Mantis.Config()
        config.cropViewConfig.showAttachedRotationControlView = false
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
        config.cropToolbarConfig.mode = .embedded
        let cropViewController: NBMantisController = Mantis.cropViewController(image: image.image, config: config)
        cropViewController.delegate = self
        withNavigation { navigation in
            navigation.pushViewController(cropViewController, animated: true)
        }
    }
    
    func cropDone(thumbnail: NBThumbnail) {
        let resultView = SelectSpeciesView(flow: self, thumbnail: thumbnail)
        withNavigation { navigation in
            navigation.pushViewController(resultView.setUpViewController(), animated: true)
        }
    }
    
    @MainActor func existingSound(mediaId: UUID, prevSoundFromTo: SoundFromTo?) {
        withNavigation { navigation in
            navigation.pushViewController(SpectrogramViewController(mediaId: mediaId, flow: self, prevSoundFromTo: prevSoundFromTo), animated: true)
        }
    }
    
    @MainActor func spectrogramCropDone(sound: NBSound, crop: NBThumbnail, start: Int, end: Int) {
        soundData.sound = sound
        soundData.crop = crop
        data.thumbnail = crop
        soundData.start = start
        soundData.end = end
        let resultView = SelectSpeciesView(flow: self, thumbnail: crop)
        withNavigation { navigation in
            navigation.pushViewController(resultView.setUpViewController(), animated: true)
        }
    }
    
    @MainActor func setSpeciesAvatar(avatar: UIImage?) {
        if let avatar = avatar {
            speciesAvatar = Image(uiImage: avatar)
        } else {
            speciesAvatar = Image("placeholder")
        }
    }
    
    @MainActor func selectSpecies(species: SpeciesListItem?) {
        data.species = species
        if let speciesUrl = species?.url {
            Task {
                setSpeciesAvatar(avatar: await URLSession.shared.cachedImage(url: URL(string: Configuration.djangoUrl + speciesUrl)!))
            }
        } else {
            setSpeciesAvatar(avatar: nil)
        }
        if let controller = viewController, let navigation = controller.navigationController {
            navigation.popToViewController(controller, animated: true)
        }
    }
    
    @MainActor private func updateResult(result: [SpeciesResult]) async {
        imageData.result = result
    }
    
    func identify() async throws -> [SpeciesResult] {
        if let thumbnail = imageData.crop {
            try await backend.upload(image: thumbnail)
            let result = try await backend.imageId(mediaId: thumbnail.id.uuidString)
            await updateResult(result: result)
            return result
        } else if let sound = soundData.sound, let start = soundData.start, let end = soundData.end {
            let result = try await backend.soundId(mediaId: sound.id.uuidString, start: start, end: end)
            await updateResult(result: result)
            return result
        } else {
            Fail.with(message: "Can not identify sound or image without complete data")
        }
    }
    
    @MainActor func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        let thumbnail = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
            cropped.draw(in: CGRect(origin: .zero, size: .thumbnail))
        }
        let crop = NBThumbnail(image: thumbnail)
        imageData.crop = crop
        data.thumbnail = crop
        imageData.result = nil
        withNavigation { navigation in
            cropDone(thumbnail: crop)
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        cropViewController.navigationController?.popViewController(animated: true)
    }
    
    func cancel() {
        if let controller = viewController, let navigation = controller.navigationController {
            data.thumbnail = nil
            navigation.popToViewController(controller, animated: true)
        }
    }

    func saveObservation() {
        if let navigation = navigationController {
            do {
                try backend.persistence.insert(data: data)
                navigation.forcePopViewController(animated: true)
            } catch {
                Fail.with(error)
            }
        }
    }
    
    @MainActor
    func resetRegion() {
        region = data.region
    }
    
    @MainActor
    func pickCoordinate() {
        data.coords = Coordinates(region: region)
        region = data.region
    }
    
    func searchSpecies() {
        withNavigation { navigation in
            navigation.pushViewController(PickSpeciesListViewController(flow: self), animated: true)
        }
    }
    
    func isImage() -> Bool {
        data.obsType == .image || data.obsType == .unidentifiedimage
    }
}
