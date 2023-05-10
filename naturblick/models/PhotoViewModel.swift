//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class PhotoViewModel : ObservableObject {
    
    @Published private(set) var img: UIImage? = nil
    
    var crop: UIImage? {
        get {
            guard let uiImg = img else { return nil }
            guard let cgImg = uiImg.cgImage else { return nil }
            
            let x = uiImg.size.width / 2 - 448 / 2
            let y = uiImg.size.height / 2 - 448 / 2
            
            guard let crop = cgImg.cropping(to:  CGRect(x: x, y: y, width: 448, height: 448)) else { return nil }
            
            return UIImage(cgImage: crop)
        }
    }
    
    func setImage(img: UIImage) {
        self.img = img
        savePhoto(img: img)
    }
    
    func savePhoto(img: UIImage) {
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}
