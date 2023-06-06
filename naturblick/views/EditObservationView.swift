//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

struct EditObservationView: View {
    @Binding var data: EditData
    @State private var showMap: Bool = false
    @State private var region: MKCoordinateRegion
    
    init(data: Binding<EditData>) {
        self._data = data
        self._region = State(initialValue: data.wrappedValue.region)
    }
    
    var body: some View {
        Form {
            CoordinatesView(coordinates: data.coords)
                .onTapGesture {
                    showMap = true
                }
            NBEditText(label: "Notes", iconAsset: "details", text: $data.details)
        }
        .fullScreenCover(isPresented: $showMap) {
            NavigationView {
                Map(coordinateRegion: $region)
                    .picker()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                region = data.region
                                showMap = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                data.coords = Coordinates(region: region)
                                showMap = false
                            }
                        }
                    }
            }
        }
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        EditObservationView(data: .constant(EditData(observation: Observation.sampleData)))
    }
}
