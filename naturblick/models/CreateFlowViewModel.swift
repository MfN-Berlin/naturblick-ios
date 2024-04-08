//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI
import Mantis
import MapKit
import Photos

extension View {
    func permissionSettingsDialog(isPresented: Binding<Bool>, presenting: String?) -> some View {
        self.confirmationDialog("open_settings", isPresented: isPresented, presenting: presenting) { _ in
            Button("open_settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: { message in
            Text(message)
        }
    }
}

class CreateFlowViewModel: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, IdFlow, PickerFlow, HoldingViewController {
    
    var holder: ViewControllerHolder = ViewControllerHolder()
    let client = BackendClient()
    @Published private(set) var result: [SpeciesResult]? = nil
    let persistenceController: ObservationPersistenceController
    @Published var data = CreateData()
    @Published var region: MKCoordinateRegion = .defaultRegion
    @Published var speciesAvatar: Image = Image("placeholder")
    @Published var showOpenSettings: Bool = false
    @Published var openSettingsMessage: String? = nil
    var isCreate: Bool = true
    let fromList: Bool
    init(persistenceController: ObservationPersistenceController, fromList: Bool = false) {
        self.persistenceController = persistenceController
        self.fromList = fromList
        super.init()
        
        $data.map { data in
            data.image.result
          }.assign(to: &$result)
    }

    @MainActor
    func takePhoto() {
        data = CreateData()
        region = .defaultRegion
        speciesAvatar = Image("placeholder")
        Task { @MainActor in
            if PHPhotoLibrary.askForPermission() {
                await PHPhotoLibrary.requestAccess()
            }
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var accessGranted = false
            if  status == .notDetermined {
                accessGranted = await AVCaptureDevice.requestAccess(for: .video)
            } else if status == .authorized {
                accessGranted = true
            } else {
                // User has previously denied the permission, but ask to take a photo again
                openSettingsMessage = String(localized: "go_to_app_settings_photo")
                showOpenSettings = true
            }
            
            guard accessGranted else {
                return
            }
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            withNavigation { navigation in
                navigation.present(imagePicker, animated: true)
            }
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
    
    func cropDone(thumbnail: NBThumbnail) {
        let resultView = SelectSpeciesView(flow: self, thumbnail: thumbnail)
        withNavigation { navigation in
            navigation.pushViewController(resultView.setUpViewController(), animated: true)
        }
    }
    
    @MainActor func recordSound() {
        data = CreateData()
        region = .defaultRegion
        speciesAvatar = Image("placeholder")
        Task { @MainActor in
            let status = AVAudioSession.sharedInstance().recordPermission
            var accessGranted = false
            
            if status == .undetermined {
                accessGranted = await AVAudioSession.sharedInstance().requestRecordPermission()
            } else if status == .granted {
                accessGranted = true
            } else {
                // User has previously denied the permission, but ask to record a bird again
                openSettingsMessage = String(localized: "go_to_app_settings_microphone")
                showOpenSettings = true
            }

            guard accessGranted else {
                return
            }
            
            withNavigation { navigation in
                let soundRecorder = BirdRecorderView(flow: self)
                navigation.pushViewController(soundRecorder.setUpViewController(), animated: true)
            }
        }
    }
    
    @MainActor func soundRecorded(sound: NBSound) {
        withNavigation { navigation in
            var viewControllers = navigation.viewControllers
            viewControllers[viewControllers.count - 1] = SpectrogramViewController(mediaId: sound.id, flow: self)
            navigation.setViewControllers(viewControllers, animated: true)
        }
    }
    
    @MainActor func spectrogramCropDone(sound: NBSound, crop: NBThumbnail, start: Int, end: Int) {
        data.sound.sound = sound
        data.sound.crop = crop
        data.sound.start = start
        data.sound.end = end
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
                setSpeciesAvatar(avatar: await URLSession.shared.cachedImage(url: URL(string: Configuration.strapiUrl + speciesUrl)!))
            }
        }
        let create = CreateObservationView(createFlow: self).setUpViewController()
        navigationController?.pushViewController(create, animated: true)
    }
    
    @MainActor func selectManual(species: SpeciesListItem) {
        data = CreateData()
        data.species = species
        region = .defaultRegion
        speciesAvatar = Image("placeholder")
        if let speciesUrl = species.url {
            Task {
                setSpeciesAvatar(avatar: await URLSession.shared.cachedImage(url: URL(string: Configuration.strapiUrl + speciesUrl)!))
            }
        }
        let create = InSheetPopAwareNavigationController(rootViewController: CreateObservationView(createFlow: self).setUpViewController())
        viewController?.present(create, animated: true)
    }
    
    @MainActor private func updateResult(result: [SpeciesResult]) {
        data.image.result = result
    }
    
    func identify() async throws -> [SpeciesResult] {
        if let thumbnail = data.image.crop {
            try await client.upload(image: thumbnail)
            let result = try await client.imageId(mediaId: thumbnail.id.uuidString)
            updateResult(result: result)
            return result
        } else if let sound = data.sound.sound, let start = data.sound.start, let end = data.sound.end {
            let result = try await client.soundId(mediaId: sound.id.uuidString, start: start, end: end)
            updateResult(result: result)
            return result
        } else {
            preconditionFailure("Can not identify sound or image without complete data")
        }
    }
    
    @MainActor func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        Task {
            do {
                let image = try await NBImage(image: selectedImage)
                cropPhoto(image: image)
                picker.dismiss(animated: true)
            } catch {
                preconditionFailure("\(error)")
            }
        }
    }
    
    @MainActor func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        let thumbnail = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
            cropped.draw(in: CGRect(origin: .zero, size: .thumbnail))
        }
        do {
            let crop = try NBThumbnail(image: thumbnail)
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
                var controllers = navigation.viewControllers
                if fromList {
                    controllers.removeLast(controllers.count - 2)
                } else {
                    controllers.removeLast(controllers.count - 1)
                    controllers.append(ObservationListViewController())
                }
                navigation.setViewControllers(controllers, animated: true)
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
    
    func searchSpecies() {
        withNavigation { navigation in
            let view = PickSpeciesListView(flow: self)
            navigation.pushViewController(view.setUpViewController(), animated: true)
        }
    }
    
    func isImage() -> Bool {
        data.obsType == .image || data.obsType == .unidentifiedimage
    }
}
