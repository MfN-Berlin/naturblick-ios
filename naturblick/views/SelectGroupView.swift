//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

enum GroupSelection: Hashable, Identifiable {
    var id: Self {
        return self
    }
    var description: String {
        switch(self) {
        case .all: return String(localized: "filter_all")
        case .unknown: return String(localized: "filter_unknown")
        case .other: return String(localized: "filter_others")
        case let .group(group): return group.name
        }
    }
    case all
    case unknown
    case other
    case group(NamedGroup)
}

protocol GroupSelector: ObservableObject {
    var group: GroupSelection { get set }
    var groups: [NamedGroup] { get }
}

struct SelectGroupView<P, GS>: NavigatableView where P: ObservationProvider, GS: GroupSelector {
    var holder: ViewControllerHolder = ViewControllerHolder()
    @ObservedObject var selector: GS
    @ObservedObject var provider: P
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "cancel")) {_ in
            viewController?.dismiss(animated: true)
        })
    }

    var groups: [GroupSelection] {
        let fieldbookGroups = selector.groups
        let groupIds = Set(provider.observations.map { observation in
            observation.species?.group.id
        })
        let hasUnknown = groupIds.contains(nil)
        let knownGroupIds = groupIds.compactMap({$0})
        let hasOther = knownGroupIds.contains { id in
            return !fieldbookGroups.contains { group in
                group.id == id
            }
        }
        let selectableGroups = knownGroupIds
            .compactMap { id in
                let groupMatch = fieldbookGroups.first {
                    group in group.id == id
                }
                guard let group = groupMatch else {
                    return nil as NamedGroup?
                }
                return group
            }
            .sorted(by: {$0.name < $1.name})
            .map { group in
                GroupSelection.group(group)
            }
        return [GroupSelection.all] + (hasUnknown ? [GroupSelection.unknown] : []) + selectableGroups + (hasOther ? [GroupSelection.other] : [])
    }
    
    var body: some View {
        VStack {
            List(groups, id: \.self) { group in
                let selected = selector.group == group
                HStack(alignment: .center) {
                    Text(group.description)
                        .subtitle1(color: selected ? Color.onPrimaryButtonSecondary : Color.onSecondaryHighEmphasis)
                    Spacer()
                    ChevronView()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selector.group = group
                    viewController?.dismiss(animated: true)
                }
                .listRowInsets(.nbInsets)
                .listRowBackground(selected ? Color.primary : Color.secondaryColor)
            }
            .listStyle(.plain)
        }
    }
}
