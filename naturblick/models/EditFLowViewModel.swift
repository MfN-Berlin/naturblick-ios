//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit
import MapKit
import Mantis

class EditFlowViewModel: NSObject, CropViewControllerDelegate, IdFlow, PickerFlow, HoldingViewController {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let client = BackendClient()
    @Published private(set) var result: [SpeciesResult]? = nil
    let persistenceController: ObservationPersistenceController
    @Published var data: EditData
    @Published var imageData: ImageData = ImageData()
    @Published var editing: Bool = false
    @Published var region: MKCoordinateRegion
    init(persistenceController: ObservationPersistenceController, observation: Observation) {
        self.persistenceController = persistenceController
        let data = EditData(observation: observation)
        self.data = data
        self.region = data.region
        super.init()
        
        $imageData.map { data in
            data.result
        }.assign(to: &$result)
        
        if let thumbnailId = observation.observation.thumbnailId {
            Task {
                let thumbnail = try await NBImage(id: thumbnailId)
                await setThumbnail(thumbnail: thumbnail)
            }
        }
    }
    
    @MainActor private func setThumbnail(thumbnail: NBImage) async {
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
    
    func cropDone(thumbnail: NBImage) {
        let resultView = SelectSpeciesView(createFlow: self, thumbnail: thumbnail)
        withNavigation { navigation in
            navigation.pushViewController(resultView.setUpViewController(), animated: true)
        }
    }
    
    @MainActor func selectSpecies(species: SpeciesListItem) {
        data.species = species
        if let controller = viewController, let navigation = controller.navigationController {
            navigation.popToViewController(controller, animated: true)
        }
    }
    
    @MainActor private func updateResult(result: [SpeciesResult]) async {
        imageData.result = result
    }
    
    func identify() async throws {
        if let thumbnail = imageData.crop {
            try await client.upload(image: thumbnail)
            let result = try await client.imageId(mediaId: thumbnail.id.uuidString)
            await updateResult(result: result)
        }
    }
    
    @MainActor func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        let thumbnail = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
            cropped.draw(in: CGRect(origin: .zero, size: .thumbnail))
        }
        do {
            let crop = NBImage(image: thumbnail)
            try crop.write()
            imageData.crop = crop
            withNavigation { navigation in
                cropDone(thumbnail: crop)
            }
        } catch {
            preconditionFailure("\(error)")
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        cropViewController.navigationController?.popViewController(animated: true)
    }
    
    func saveObservation() {
        if let navigation = navigationController {
            do {
                try persistenceController.insert(data: data)
                navigation.popViewController(animated: true)
            } catch {
                preconditionFailure("\(error)")
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
}
