//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CoordinatesView: View {
    let coordinates: Coordinates?
    var body: some View {
        if let latitude = coordinates?.latitude,
           let longitude = coordinates?.longitude {
            Text("\(longitude), \(latitude)")
        } else {
            Text("No coordinates")
        }
    }
}

struct CoordinatesView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatesView(coordinates: .defaultCoordinates)
    }
}
