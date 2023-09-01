//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

extension UIViewController {
    func setUpDefaultNavigationItemApperance() {
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
            .foregroundColor: Color.onPrimaryHighEmphasisUi,
            .font: latoBlack19
        ]
        appearance.titleTextAttributes = attrs
        appearance.largeTitleTextAttributes = attrs
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }
}

public class ViewControllerHolder {
    public weak var viewController: UIViewController?
    
    public init() {}
}

public protocol NavigatableView: View {
    var holder: ViewControllerHolder { get set }
    var title: String? { get }
    func configureNavigationItem(item: UINavigationItem)
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

    func withNavigation(block: (_ navigation: UINavigationController) -> Void) {
        if let navigation = viewController?.navigationController {
            block(navigation)
        }
    }
    
    var title: String? {
        nil
    }

    func configureNavigationItem(item: UINavigationItem) {
    }
}

public class HostingController<ContentView>: UIHostingController<ContentView> where ContentView: NavigatableView {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpDefaultNavigationItemApperance()
        if let title = rootView.title {
            navigationItem.title = title
        }
        rootView.configureNavigationItem(item: navigationItem)
    }

    
    public override init(rootView: ContentView) {
        super.init(rootView: rootView)
    }
    
    // Called when initialized from storyboard
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
}
