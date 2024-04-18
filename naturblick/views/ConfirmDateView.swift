//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ConfirmDateView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()

    @ObservedObject var createFlow: CreateFlowViewModel
    @State var date: Date
    
    let timeZones = TimeZone.knownTimeZoneIdentifiers
    @State var selectedTimeZone: Int
    
    init(createFlow: CreateFlowViewModel) {
        self.createFlow = createFlow
        self.date = createFlow.data.created.date
        let tz = try! createFlow.data.coords?.timezone() ?? TimeZone(identifier: TimeZone.current.identifier)
        if let tzIndex = timeZones.firstIndex(of: tz!.identifier) {
            selectedTimeZone = tzIndex
        } else {
            selectedTimeZone = 0
        }
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "set_time")) {_ in
            createFlow.data.created = ZonedDateTime(date: date, tz: TimeZone(identifier: timeZones[selectedTimeZone])!)
            createFlow.showCreateView()
        })
    }
    
    var body: some View {
        VStack {
            Text("validate_time")
                .headline4()
            Text("validate_time_msg")
                .body1()
            DatePicker("", selection: $date)
                .labelsHidden()
            
            Picker(selection: $selectedTimeZone, label: Text("timezone")) {
                ForEach(0 ..< timeZones.count) {
                    Text(self.timeZones[$0]).tag($0)
                }
            }
            Spacer()
        }.padding()
    }
}
