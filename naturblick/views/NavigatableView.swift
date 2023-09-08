//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


public class ViewControllerHolder {
    public weak var viewController: UIViewController?
    
    public init() {}
}

public protocol HoldingViewController {
    var holder: ViewControllerHolder { get set }
    func setViewController(controller: UIViewController)
}

extension HoldingViewController {
    func setViewController(controller: UIViewController) {
        holder.viewController = controller
    }
    
    var viewController: UIViewController? {
        return holder.viewController
    }
    
    var navigationController: UINavigationController? {
        return viewController?.navigationController
    }
    
    func withNavigation(block: (_ navigation: UINavigationController) -> Void) {
        if let navigation = navigationController {
            block(navigation)
        }
    }
}

extension UIViewController {
    func setUpDefaultNavigationItemApperance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.onPrimaryButtonSecondary
        guard let latoBlack19 = UIFont(name: "Lato-Black", size: 19) else {
            fatalError("""
                       Failed to load the "Lato-Black" font.
                       Make sure the font file is included in the project and the font name is spelled correctly.
                       """
            )
        }
        
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.onPrimaryHighEmphasis,
            .font: latoBlack19
        ]
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = attrs
        buttonAppearance.disabled.titleTextAttributes = attrs
        buttonAppearance.focused.titleTextAttributes = attrs
        buttonAppearance.highlighted.titleTextAttributes = attrs
        appearance.buttonAppearance = buttonAppearance
        appearance.backButtonAppearance = buttonAppearance
        appearance.doneButtonAppearance = buttonAppearance
        appearance.titleTextAttributes = attrs
        appearance.largeTitleTextAttributes = attrs
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }
}

public protocol HostedView: View, HoldingViewController {
    var title: String? { get }
    func configureNavigationItem(item: UINavigationItem)
}

public extension HostedView {
    var title: String? {
        nil
    }

    func configureNavigationItem(item: UINavigationItem) {
    }
}

public protocol NavigatableView: View, HoldingViewController {
    var title: String? { get }
    func configureNavigationItem(item: UINavigationItem)
}

public extension NavigatableView {
    func setUpViewController() -> UIViewController {
        let viewController = NavigatableHostingController(rootView: self)
        return viewController
    }
    
    var title: String? {
        nil
    }

    func configureNavigationItem(item: UINavigationItem) {
    }
}

public class HostingController<ContentView>: UIHostingController<ContentView>  where ContentView: HostedView {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpDefaultNavigationItemApperance()
        if let title = rootView.title {
            navigationItem.title = title
        }
        view.backgroundColor = UIColor.secondary
        rootView.configureNavigationItem(item: navigationItem)
    }
    
    public override init(rootView: ContentView) {
        super.init(rootView: rootView)
        rootView.setViewController(controller: self)
    }
    
    // Called when initialized from storyboard
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}

private class NavigatableHostingController<ContentView>: UIHostingController<ContentView> where ContentView: NavigatableView {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpDefaultNavigationItemApperance()
        if let title = rootView.title {
            navigationItem.title = title
        }
        view.backgroundColor = UIColor.secondary
        rootView.configureNavigationItem(item: navigationItem)
    }
    
    public override init(rootView: ContentView) {
        super.init(rootView: rootView)
        rootView.setViewController(controller: self)
    }
    
    // Called when initialized from storyboard
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
}
