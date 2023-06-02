//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CropView: View {
    
    @Binding var imageIdState: ImageIdState
    @Binding var data: CreateData
    
    func crop(img: UIImage) -> UIImage? {
        guard let cgImg = img.cgImage else { return nil }
        
        let x = img.size.width / 2 - 448 / 2
        let y = img.size.height / 2 - 448 / 2
        
        guard let crop = cgImg.cropping(to:  CGRect(x: x, y: y, width: 448, height: 448)) else { return nil }
        
        return UIImage(cgImage: crop)
    }
        
    
    var body: some View {
        BaseView {
            VStack {
                if let img = data.img {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Rectangle())
                        .frame(width: 300, height: 300)
                    
                    Button {
                        data.crop = crop(img: img)
                        imageIdState = .chooseResult
                    } label: {
                        Text("crop it")
                    }
                } else {
                    Text("no image to crop")
                }
            }
        }
    }
}
