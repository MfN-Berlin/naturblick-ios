//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import MapKit

protocol PickerFlow: ObservableObject {
    var region: MKCoordinateRegion {get set}
    func resetRegion()
    func pickCoordinate()
}
