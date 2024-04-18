//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import PhotosUI
import SwiftUI
import Photos

protocol ImagePickerDelegate {
    func pickedFromPhotos(uiImage: UIImage, assetResult: AssetResult)
}

class ImagePickerController: HostingController<ImagePicker> {
}

struct AssetResult {
    let localIdentifier: String
    let location: CLLocation?
    let creationDate: ZonedDateTime?
}

struct ImagePicker: UIViewControllerRepresentable, HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var delegate: ImagePickerDelegate
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            if let result = results.first {
                let itemProvider: NSItemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let uiImage = image as? UIImage {
                            self.parent.delegate.pickedFromPhotos(uiImage: uiImage, assetResult: self.getAssetResult(result: result)!)
                        }
                    }
                }
            }
        }
        
        private func getAssetResult(result: PHPickerResult) -> AssetResult? {
            if let assetId = result.assetIdentifier, let phResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject {
                AssetResult(localIdentifier: phResult.localIdentifier, location: phResult.location, creationDate: phResult.creationDate.map {
                    d in ZonedDateTime(date: d, tz: TimeZone(secondsFromGMT: 0)!)
                } )
            } else {
                nil
            }
        }
    }
}
