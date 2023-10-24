//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import Mantis

class NBMantisController: Mantis.CropViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDefaultNavigationItemApperance(hideShadow: false, inSheet: navigationController as? InSheetPopAwareNavigationController != nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "identify_species"), style: .done, target: self, action: #selector(NBMantisController.createCrop))
        navigationItem.title = String(localized: "crop")
        navigationItem.titleView = UIView()
    }
    
    @objc func createCrop() {
        crop()
    }
}
