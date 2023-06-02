//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import UIKit
import SwiftUI

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var picker: ImagePickerView
    var data: Binding<CreateData>
    
    init(picker: ImagePickerView, data: Binding<CreateData>) {
        self.picker = picker
        self.data = data
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        data.wrappedValue.img = selectedImage
        UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
        self.picker.imageIdState = .crop
    }
    
}
