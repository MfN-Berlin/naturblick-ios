//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CoordinatesView: View {
    let coordinates: Coordinates?
    var body: some View {
        if let coordinates = coordinates {
            Text(coordinates.asString())
        } else {
            Text("no_coordinates")
        }
    }
}

struct CoordinatesView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatesView(coordinates: .defaultCoordinates)
    }
}
