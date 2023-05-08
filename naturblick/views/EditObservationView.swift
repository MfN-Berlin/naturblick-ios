//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct EditObservationView: View {
    @Binding var data: EditData
    var body: some View {
        Form {
                if let latitude = data.coords?.latitude,
                   let longitude = data.coords?.longitude {
                    Text("\(longitude), \(latitude)")
                }
                NBEditText(label: "Notes", iconAsset: "details", text: $data.details)
            }
             
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        EditObservationView(data: .constant(EditData(observation: Observation.sampleData)))
    }
}
