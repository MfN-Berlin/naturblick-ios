//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

public class ViewControllerHolder {
    public weak var viewController: UIViewController?
    
    public init() {}
}

public protocol NavigatableView: View {
    var holder: ViewControllerHolder { get set }
    var title: String? { get }
    func configureNavigationItem(item: UINavigationItem) -> UINavigationItem
}

public extension NavigatableView {
    func setUpViewController() -> UIViewController {
        let viewController = HostingController(rootView: self)
        self.holder.viewController = viewController
        return viewController
    }
    
    var viewController: UIViewController? {
        return holder.viewController
    }

    var title: String? {
        nil
    }

    func configureNavigationItem(item: UINavigationItem) -> UINavigationItem {
        return item
    }
}

public class HostingController<ContentView>: UIHostingController<ContentView> where ContentView: NavigatableView {
    public override var navigationItem: UINavigationItem {
        var item = super.navigationItem
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Color.onPrimaryButtonSecondaryUi
        guard let latoBlack19 = UIFont(name: "Lato-Black", size: 19) else {
            fatalError("""
                       Failed to load the "Lato-Black" font.
                       Make sure the font file is included in the project and the font name is spelled correctly.
                       """
            )
        }
        
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(.onPrimaryHighEmphasis),
            .font: latoBlack19
        ]
        appearance.titleTextAttributes = attrs
        appearance.largeTitleTextAttributes = attrs
        item.standardAppearance = appearance
        item.compactAppearance = appearance
        item.scrollEdgeAppearance = appearance
        item.compactScrollEdgeAppearance = appearance
        if let title = rootView.title {
            item.title = title
        }
        return rootView.configureNavigationItem(item: item)
    }

}
