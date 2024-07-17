//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class CCByPopupViewController: HostingController<CCByPopupView>, UIAdaptivePresentationControllerDelegate {
    let finishAction: () -> Void
    init(finishAction: @escaping () -> Void) {
        self.finishAction = finishAction
        super.init(rootView: CCByPopupView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.presentationController?.delegate = self
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        finish()
    }
    
    func finish() {
        UserDefaults.standard.setValue(true, forKey: "ccByNameWasSet")
        finishAction()
    }
    
    @objc func dismissAndFinish() {
        dismiss(animated: true)
        finish()
    }
    
}

struct CCByPopupView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    @AppStorage("ccByName") var ccByName: String = "MfN Naturblick"

    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(title: String(localized: "ok"), style: .done, target: viewController, action: #selector(CCByPopupViewController.dismissAndFinish))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text("cc_by_msg")
                    .body1()
                
                HStack {
                    Image(decorative: "create_24px")
                        .observationProperty()
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: .zero) {
                        Text("cc_by_field")
                            .caption(color: .onSecondarySignalLow)
                        TextField(String(localized: "cc_by_field"), text: $ccByName)
                    }
                }
            }
        }.padding(.defaultPadding)
    }
}
