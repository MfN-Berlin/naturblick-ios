//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit
import Mantis

class CreateFlowViewModel: NSObject, ObservableObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate {
    let persistenceController: ObservationPersistenceController
    let client = BackendClient()
    var didCapture = false
    @Published var data = CreateData()
    @Published var openResultView: NBImage? = nil
    @Published var openCropperView: NBImage? = nil
    
    init(persistenceController: ObservationPersistenceController) {
        self.persistenceController = persistenceController
    }
    
    @MainActor func takePhoto(navigation: UINavigationController) {
        guard !didCapture else {
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        navigation.present(imagePicker, animated: true) {
            self.didCapture = true
        }
    }
    
    @MainActor func cropPhoto(navigation: UINavigationController, image: NBImage) {
        var config = Mantis.Config()
        config.cropViewConfig.showAttachedRotationControlView = false
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
        let cropViewController: NBMantisController = Mantis.cropViewController(image: image.image, config: config)
        cropViewController.delegate = self
        navigation.pushViewController(cropViewController, animated: true)
    }
    
    @MainActor func selectSpecies(navigation: UINavigationController, thumbnail: NBImage) {
        let resultView = SelectSpeciesView(createFlow: self, thumbnail: thumbnail) {_ in
            
        }
        navigation.pushViewController(resultView.setUpViewController(), animated: false)
    }
    
    @MainActor func createObservation(navigation: UINavigationController, species: SpeciesListItem) {
        data.species = species
        let create = CreateObservationViewController(createFlow: self)
        navigation.popViewController(animated: false)
        navigation.popViewController(animated: false)
        navigation.pushViewController(create, animated: false)
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
            openCropperView = image
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
            openResultView = crop
            Task {
                do {
                    try await client.upload(image: crop)
                    updateResult(result: try await client.imageId(mediaId: crop.id.uuidString))
                } catch {
                    print("\(error)")
                }
            }
        } catch {
            preconditionFailure("\(error)")
        }
    }
    
    @MainActor func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        cropViewController.navigationController?.popViewController(animated: true)
    }
    
    @MainActor 	func saveObservation(navigation: UINavigationController) {
        do {
            try persistenceController.insert(data: data)
            navigation.popViewController(animated: true)
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
