//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CreateObservationView: View {
    @Binding var createOperation: CreateOperation

    var body: some View {
        Form {
            NBEditText(label: "Notes", iconAsset: "details", text: $createOperation.details)
        }
    }
}

struct ObservationEditView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(createOperation: .constant(CreateOperation()))
    }
}
