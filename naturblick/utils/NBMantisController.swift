//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import Mantis

class NBMantisController: Mantis.CropViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDefaultNavigationItemApperance()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Crop", style: .done, target: self, action: #selector(NBMantisController.createCrop))
        navigationItem.title = "Crop"
        navigationItem.titleView = UIView()
    }
    
    @objc func createCrop() {
        crop()
    }
}
