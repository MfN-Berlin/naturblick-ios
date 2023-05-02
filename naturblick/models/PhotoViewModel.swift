//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class PhotoViewModel : ObservableObject {
    
    @Published private(set) var img: UIImage = UIImage(systemName: "snow")!
    
    func setImage(img: UIImage) {
        self.img = img
        savePhoto(img: img)
    }
    
    func savePhoto(img: UIImage) {
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}
