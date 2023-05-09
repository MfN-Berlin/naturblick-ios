//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import UIKit
import SwiftUI

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var picker: ImagePickerView
    var photoViewModel: PhotoViewModel
    
    init(picker: ImagePickerView, photoViewModel: PhotoViewModel) {
        self.picker = picker
        self.photoViewModel = photoViewModel
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        photoViewModel.setImage(img: selectedImage)
        self.picker.isPresented.wrappedValue.dismiss()
    }
    
}
