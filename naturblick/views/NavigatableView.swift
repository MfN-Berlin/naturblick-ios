//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

public protocol PopAware {
    func pop() -> Bool
}

extension PopAware {
    func pop() -> Bool {
        return true
    }
}

class PopAwareNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.tintColor = UIColor.onPrimaryHighEmphasis
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        if let vc = topViewController as? PopAware, !vc.pop() {
            return self
        } else {
            return super.popViewController(animated: animated)
        }
    }
    
    func forcePopViewController(animated: Bool) {
        let _ = super.popViewController(animated: animated)
    }
}

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
    
    var navigationController: PopAwareNavigationController? {
        return viewController?.navigationController as? PopAwareNavigationController
    }
    
    func withNavigation(block: (_ navigation: UINavigationController) -> Void) {
        if let navigation = navigationController {
            block(navigation)
        }
    }
}

extension UIViewController {
    func setUpDefaultNavigationItemApperance(hideShadow: Bool) {
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
        if hideShadow {
            appearance.shadowColor = .clear
        }
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }
}

public protocol HostedView: View, HoldingViewController, PopAware {
    var viewName: String? { get }
    var alwaysDarkBackground: Bool { get }
    var hideNavigationBarShadow: Bool { get }
    func configureNavigationItem(item: UINavigationItem)
}

public extension HostedView {
    var viewName: String? {
        nil
    }
    var alwaysDarkBackground: Bool  {
        false
    }
    var hideNavigationBarShadow: Bool {
        false
    }
    func configureNavigationItem(item: UINavigationItem) {
    }
}

public protocol NavigatableView: View, HoldingViewController, PopAware {
    var viewName: String? { get }
    var alwaysDarkBackground: Bool { get }
    var hideNavigationBarShadow: Bool { get }
    func configureNavigationItem(item: UINavigationItem)
}

public extension NavigatableView {
    func setUpViewController() -> UIViewController {
        let viewController = NavigatableHostingController(rootView: self)
        return viewController
    }
    
    var viewName: String? {
        nil
    }

    var alwaysDarkBackground: Bool  {
        false
    }

    var hideNavigationBarShadow: Bool {
        false
    }

    func configureNavigationItem(item: UINavigationItem) {
    }
}

public class HostingController<ContentView>: UIHostingController<ContentView>, PopAware where ContentView: HostedView {
    public func pop() -> Bool {
        return rootView.pop()
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpDefaultNavigationItemApperance(hideShadow: rootView.hideNavigationBarShadow)
        if let title = rootView.viewName {
            navigationItem.title = title
        }
        navigationItem.titleView = UIView()
        view.backgroundColor = rootView.alwaysDarkBackground ? .primaryHome : .secondary
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
    
    func setupSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        
        let sb = searchController.searchBar
       
        let stf = sb.searchTextField
        let glasIconView = searchController.searchBar.searchTextField.leftView as? UIImageView
        
        glasIconView?.tintColor = .onPrimaryMininumEmphasis
        stf.attributedPlaceholder = NSAttributedString(
            string: String(localized: "search"),
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.onPrimaryMininumEmphasis]
        )
        
        stf.textColor = .onPrimaryHighEmphasis
        stf.backgroundColor = UIColor.onPrimaryInput
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = false
        return searchController
    }
}

private class NavigatableHostingController<ContentView>: UIHostingController<ContentView>, PopAware where ContentView: NavigatableView {
    public func pop() -> Bool {
        return rootView.pop()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpDefaultNavigationItemApperance(hideShadow: rootView.hideNavigationBarShadow)
        if let title = rootView.viewName {
            navigationItem.title = title
        }
        navigationItem.titleView = UIView()
        view.backgroundColor = rootView.alwaysDarkBackground ? .primaryHome : .secondary
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
