//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit
import Mantis

class CreateFlowViewModel: NSObject, ObservableObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, HoldingViewController {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    let persistenceController: ObservationPersistenceController
    @Published var data = CreateData()
    
    init(persistenceController: ObservationPersistenceController) {
        self.persistenceController = persistenceController
    }
    
    @MainActor func takePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        withNavigation { navigation in
            navigation.present(imagePicker, animated: true)
        }
    }
    
    private func cropPhoto(image: NBImage) {
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
    
    func selectSpecies(thumbnail: NBImage) {
        let resultView = SelectSpeciesView(createFlow: self, thumbnail: thumbnail)
        withNavigation { navigation in
            navigation.pushViewController(resultView.setUpViewController(), animated: true)
        }
    }
    
    @MainActor func createObservation(species: SpeciesListItem) {
        data.species = species
        let create = CreateObservationView(createFlow: self)
        if let navigation = viewController?.navigationController {
            navigation.pushViewController(create.setUpViewController(), animated: true)
        }
    }
    
    @MainActor func updateResult(result: [SpeciesResult]) {
        data.image.result = result
    }
    
    @MainActor func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        do {
            let image = NBImage(image: selectedImage)
            try image.writeToAlbum()
            data.image.image = image
            data.image.crop = nil
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
            withNavigation { navigation in
                selectSpecies(thumbnail: crop)
            }
        } catch {
            preconditionFailure("\(error)")
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        cropViewController.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveObservation() {
        if let controller = viewController, let navigation = controller.navigationController {
            do {
                try persistenceController.insert(data: data)
                navigation.popToViewController(controller, animated: true)
                data = CreateData()
            } catch {
                preconditionFailure("\(error)")
            }
        }
    }
}
