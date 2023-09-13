//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit
import Mantis
import MapKit

class CreateFlowViewModel: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, IdFlow, PickerFlow, HoldingViewController {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    let client = BackendClient()
    @Published private(set) var result: [SpeciesResult]? = nil
    let persistenceController: ObservationPersistenceController
    @Published var data = CreateData()
    @Published var region: MKCoordinateRegion = .defaultRegion

    init(persistenceController: ObservationPersistenceController) {
        self.persistenceController = persistenceController
        super.init()
        
        $data.map { data in
            data.image.result
          }.assign(to: &$result)
    }
    
    @MainActor func takePhoto() {
        data = CreateData()
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        withNavigation { navigation in
            navigation.present(imagePicker, animated: true)
        }
    }
    
    @MainActor private func cropPhoto(image: NBImage) {
        data.image.image = image
        data.image.crop = nil
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
        let create = CreateObservationViewController(createFlow: self)
        if let navigation = viewController?.navigationController {
            navigation.pushViewController(create, animated: true)
        }
    }
    
    @MainActor private func updateResult(result: [SpeciesResult]) {
        data.image.result = result
    }
    
    func identify() async throws {
        if let thumbnail = data.image.crop {
            try await client.upload(image: thumbnail)
            updateResult(result: try await client.imageId(mediaId: thumbnail.id.uuidString))
        }
    }
    
    @MainActor func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        do {
            let image = NBImage(image: selectedImage)
            try image.writeToAlbum()
            cropPhoto(image: image)
            picker.dismiss(animated: true)
        } catch {
            preconditionFailure("\(error)")
        }
    }
    
    @MainActor func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        let thumbnail = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
            cropped.draw(in: CGRect(origin: .zero, size: .thumbnail))
        }
        do {
            let crop = NBImage(image: thumbnail)
            try crop.write()
            data.image.crop = crop
            data.image.result = nil
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
        if let controller = viewController, let navigation = controller.navigationController {
            do {
                try persistenceController.insert(data: data)
                navigation.popToViewController(controller, animated: true)
            } catch {
                preconditionFailure("\(error)")
            }
        }
    }
    
    
    func resetRegion() {
        region = data.region
    }
    
    func pickCoordinate() {
        data.coords = Coordinates(region: region)
    }
}
