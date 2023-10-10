//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit
import BottomSheet

enum CreateObservationAction: Identifiable {
    var id: Self {
        return self
    }
    
    case createImageObservation
    case createSoundObservation
    case createManualObservation
    case createImageFromPhotosObservation
}

struct CreateObservationView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var hideNavigationBarShadow: Bool = true
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: "Save") {_ in
            createFlow.saveObservation()
        })
    }
    
    @State private var isPermissionInfoDisplay = false
    @ObservedObject var createFlow: CreateFlowViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @State private var sheetPosition : BottomSheetPosition = .dynamic
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(alignment: .center) {
                    ObservationInfoView(width: geo.size.width, data: createFlow.data) { view in
                        navigationController?.pushViewController(view, animated: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                VStack(alignment: .leading) {
                    Thumbnail(speciesUrl: createFlow.data.species?.url, thumbnailId: nil) { thumbnail in
                        HStack {
                            thumbnail
                                .avatar()
                                .padding(.trailing, .defaultPadding)
                            VStack(alignment: .leading) {
                                Text("Species")
                                    .caption(color: .onSecondarySignalLow)
                                Text(createFlow.data.species?.sciname ?? "Unknown species")
                                    .subtitle1()
                            }
                        }
                    }
                    OnSecondaryFieldView(icon: "location24") {
                        CoordinatesView(coordinates: createFlow.data.coords)
                    }
                    .onTapGesture {
                        navigationController?.pushViewController(PickerView(flow: createFlow).setUpViewController(), animated: true)
                    }
                    OnSecondaryFieldView(icon: "details") {
                        TextField("Notes", text: $createFlow.data.details)
                    }
                    OnSecondaryFieldView(icon: "location24") {
                        Picker("Behavior", selection: $createFlow.data.behavior) {
                            Text("None").tag(nil as Behavior?)
                            ForEach([Behavior].forGroup(group: createFlow.data.species?.group)) {
                                Text($0.rawValue).tag($0 as Behavior?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(.onSecondaryHighEmphasis)
                        .accentColor(.onSecondaryHighEmphasis)
                    }
                    OnSecondaryFieldView(icon: "number24") {
                        IndividualsView(individuals: $createFlow.data.individuals)
                    }
                }
                .padding(.defaultPadding)
                .padding(.bottom, geo.safeAreaInsets.bottom)
                .background(
                    RoundedRectangle(cornerRadius: .largeCornerRadius)
                        .fill(Color.secondaryColor)
                        .nbShadow()
                )
                .background(Color(uiColor: .onPrimaryButtonSecondary))
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .ignoresSafeArea(edges: .bottom)
            .frame(maxHeight: .infinity)
            .background(Color(uiColor: .onPrimaryButtonSecondary))
        }
        .onChange(of: locationManager.userLocation) { location in
            if let location = location {
                let coordinates = Coordinates(location: location)
                if createFlow.data.coords == nil {
                    createFlow.data.coords = coordinates
                    createFlow.resetRegion()
                }
            }
        }
        .onAppear {
            if(locationManager.askForPermission()) {
                locationManager.requestLocation()
            }
        }
    }
}

struct CreateObservationView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(createFlow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
