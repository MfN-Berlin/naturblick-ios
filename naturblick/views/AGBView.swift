//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class AGBViewController: HostingController<AGBView> {
    init() {
        super.init(rootView: AGBView())
    }
    
    @objc func decline() {
        let alert = UIAlertController(title: String(localized: "accept_agb_title"), message: String(localized: "accept_agb_message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "ok"), style: .default))
        present(alert, animated: true)
    }
    
    @objc func accept() {
        UserDefaults.standard.setValue(true, forKey: "agb")
        dismiss(animated: true)
    }
}

struct AGBView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()

    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(title: String(localized: "decline"), style: .plain, target: viewController, action: #selector(AGBViewController.decline))
        item.rightBarButtonItem = UIBarButtonItem(title: String(localized: "accept"), style: .done, target: viewController, action: #selector(AGBViewController.accept))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image("mfn_color_logo")
                    .resizable()
                    .scaledToFit()
                    .accessibility(hidden: true)
                Text("new_tac_greeting")
                    .body1()
                Text("new_tac_info")
                    .body1()
                Text("new_tac_authorship_title")
                    .subtitle1()
                Text("new_tac_authorship")
                    .body1()
                Text("new_tac_change_authorship")
                    .body1()
                Text("new_tac_data_collection_title")
                    .subtitle1()
                Text("new_tac_data_collection")
                    .body1()
                Text("new_tac_data_collection_sound_and_image_title")
                    .subtitle1()
                Text("new_tac_data_collection_sound_and_image")
                    .body1()
                Text("new_tac_data_collection_metadata_title")
                    .subtitle1()
                Text("new_tac_data_collection_metadata")
                    .body1()
                Text("new_tac_crashreports_title")
                    .subtitle1()
                Text("new_tac_crashreports")
                    .body1()
                Text("new_tac_data_collection_instrument_id_title")
                    .subtitle1()
                Text("new_tac_data_collection_instrument_id1")
                    .body1()
                Text("new_tac_data_collection_instrument_id2")
                    .body1()
                Text("new_tac_account_title")
                    .subtitle1()
                Text("new_tac_account")
                    .body1()
                Text("new_tac_data_collection_summary")
                    .body1()
                Text("new_tac_questions")
                    .body1()
                Text("new_tac_usage_is_acceptance")
                    .body1()
            }
            .padding(.defaultPadding)
        }
    }
}
