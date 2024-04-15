//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct AGBView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()

    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "decline")) {_ in
            let alert = UIAlertController(title: String(localized: "accept_agb_title"), message: String(localized: "accept_agb_message"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: String(localized: "ok"), style: .default))
            viewController?.present(alert, animated: true)
        })
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "accept")) {_ in
            UserDefaults.standard.setValue(true, forKey: "agb")
            viewController?.dismiss(animated: true)
        })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image("mfn_color_logo")
                    .resizable()
                    .scaledToFit()
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
