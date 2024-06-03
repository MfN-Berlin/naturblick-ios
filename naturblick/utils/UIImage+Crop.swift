//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import UIKit

extension UIImage {
    
    private func focusRect(landscape: Bool, focus: CGFloat) -> CGRect {
        let focus = focus / 100.0
        let aspectRatio = PortraitImage.focusAspectRatio(landscape: landscape)
        let origAspectRatio = size.width / size.height
        
        if origAspectRatio < aspectRatio {
            let height = size.width / aspectRatio
            let heightSpace = size.height - height
            let rect = CGRect(x: 0, y: heightSpace * focus, width: size.width, height: height)
            return rect
        } else {
            let width = size.height * aspectRatio
            let widthSpace = size.width - width
            let rect = CGRect(x: widthSpace * focus, y: 0, width: width, height: size.height)
            return rect
        }
    }
    
    func cropToFocus(landscape: Bool, focus: CGFloat) -> UIImage {
        let rect = focusRect(landscape: landscape, focus: focus)
        return UIGraphicsImageRenderer(size: rect.size, format: .noScale).image { _ in
            if let cgImage = cgImage {
                if let crop = cgImage.cropping(to: rect) {
                    let uiImageCrop = UIImage(cgImage: crop, scale: scale, orientation: imageOrientation)
                    uiImageCrop.draw(in: CGRect(origin: .zero, size: rect.size))
                }
            }
        }
    }
}
