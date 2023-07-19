//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Mantis
import SwiftUI

struct ImageCropper: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    let image: UIImage
    @Binding var crop: NBImage?
        
    class Coordinator: CropViewControllerDelegate {
        var parent: ImageCropper
        
        init(_ parent: ImageCropper) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            let thumbnail = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
                cropped.draw(in: CGRect(origin: .zero, size: .thumbnail))
            }
            parent.crop = NBImage(image: thumbnail)
        }
        
        func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeImageCropper(context: context)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

extension ImageCropper {
   
    func makeImageCropper(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropViewConfig.showAttachedRotationControlView = false
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
        let cropViewController = Mantis.cropViewController(image: image, config: config)
        cropViewController.delegate = context.coordinator

        return cropViewController
    }
}
