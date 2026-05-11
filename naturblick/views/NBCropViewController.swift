//
// Copyright © 2026 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import UIKit
import CropViewController

class NBCropViewController: CropViewController {
    override public init(image: UIImage) {
        super.init(image: image)
        hidesNavigationBar = false
        aspectRatioPreset = CGSize(width: 1, height: 1)
        aspectRatioLockEnabled = true
        resetAspectRatioEnabled = false
        aspectRatioPickerButtonHidden = true
        rotateButtonsHidden = true
        rotateClockwiseButtonHidden = true

        toolbar.clampButtonHidden = true
        toolbar.rotateCounterclockwiseButtonHidden = true
        rotateClockwiseButtonHidden = true
        resetButtonHidden = true
        doneButtonHidden = true
        cancelButtonHidden = true
        toolbar.isHidden = true

        setUpDefaultNavigationItemApperance(hideShadow: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "identify_species"), style: .done, target: self, action: #selector(NBCropViewController.createCrop))
    }

    @objc func createCrop() {
        commitCurrentCrop()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
