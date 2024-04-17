//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import UIKit

struct MenuEntry {
    let title: String
    let image: UIImage
    let handler: () -> Void
}

class MenuController : UITableViewController, UIPopoverPresentationControllerDelegate {
    private var entries: [MenuEntry] = []
    
    private let rowHeight = Int.menuRowHeight
    
    convenience init(entries: [MenuEntry], width: Int) {
        self.init(style: .plain)
        self.entries = entries
        
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: width, height: rowHeight * entries.count)
        presentationController?.delegate = self
        popoverPresentationController?.permittedArrowDirections = .up
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.rowHeight = CGFloat(rowHeight)
        tableView.separatorInset = .zero
        tableView.backgroundColor = .onPrimaryButtonSecondary

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        var contentConfig = cell.defaultContentConfiguration()
        
        let entry = entries[indexPath.row]
        
        contentConfig.text = entry.title
        contentConfig.textProperties.font = .nbBody1
        contentConfig.textProperties.color = .onPrimaryHighEmphasis

        contentConfig.image = entry.image
        contentConfig.imageProperties.tintColor = .onPrimaryHighEmphasis

        cell.contentConfiguration = contentConfig
        
        var backgroundConfiguration = cell.backgroundConfiguration
        backgroundConfiguration?.backgroundColor = .onPrimaryButtonSecondary
        cell.backgroundConfiguration = backgroundConfiguration
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.entries[indexPath.row].handler()
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
