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
            if let latitude = data.coords?.latitude,
               let longitude = data.coords?.longitude {
                Text("\(longitude), \(latitude)").onTapGesture {
                    showMap = true
                }
            }
            NBEditText(label: "Notes", iconAsset: "details", text: $data.details)
        }
        .fullScreenCover(isPresented: $showMap) {
            NavigationView {
                Map(coordinateRegion: $region)
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
                        ToolbarItem(placement: .status) {
                            Text("\(data.region.center.longitude), \(data.region.center.latitude)")
                        }
                    }
                    .overlay(alignment: .center) {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: 50)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 50, height: 2)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 4, height: 4)
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
