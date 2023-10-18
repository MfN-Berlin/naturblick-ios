//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

struct ObservationView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let client = BackendClient()
    var hideNavigationBarShadow: Bool = true
    @State var speciesAvatar: Image = Image("placeholder")
    @ObservedObject var persistenceController: ObservationPersistenceController
    @StateObject var model: ObservationViewModel
    let occurenceId: UUID
    
    init(occurenceId: UUID, persistenceController: ObservationPersistenceController) {
        self.occurenceId = occurenceId
        self.persistenceController = persistenceController
        _model = StateObject(wrappedValue: {
            ObservationViewModel(viewObservation: occurenceId, persistenceController: persistenceController)
        }())
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(title: String(localized: "edit"), primaryAction: UIAction {_ in
            if let observation = persistenceController.observations.first(where: {$0.observation.occurenceId == occurenceId}) {
                let view = EditObservationViewController(observation: observation, persistenceController: persistenceController)
                let navigation = InSheetPopAwareNavigationController(rootViewController: view)
                viewController?.present(navigation, animated: true)
            }
        })
    }
    
    var view: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                speciesAvatar
                    .avatar()
                    .padding(.trailing, .defaultPadding)
                
                VStack(alignment: .leading) {
                    Text("species")
                        .caption(color: .onSecondarySignalLow)
                    Text(model.observation?.species?.sciname ?? "unknown_species")
                        .subtitle1(color: .onSecondaryMediumEmphasis)
                }
                Spacer()
                ChevronView(color: .onSecondarySignalLow)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if let species = model.observation?.species?.listItem {
                    navigationController?.pushViewController(PortraitViewController(species: species, inSelectionFlow: true), animated: true)
                }
            }
            Divider()
            HStack {
                Image("location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("location")
                        .caption(color: .onSecondarySignalLow)
                    CoordinatesView(coordinates: model.observation?.observation.coords)
                }
                Spacer()
                ChevronView(color: .onSecondarySignalLow)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // TODO
                print("Show on map")
            }
            Divider()
            ViewProperty(icon: "number24", label: String(localized: "number"), content: String(model.observation?.observation.individuals ?? 1))
            ViewProperty(icon: "location24", label: String(localized: "behavior"), content: model.observation?.observation.behavior?.rawValue)
            ViewProperty(icon: "details", label: String(localized: "notes"), content: model.observation?.observation.details)
        }
        .task(id: model.observation?.species?.id) {
            if let speciesUrl = model.observation?.species?.listItem.url, let image = try? await client.downloadCached(speciesUrl: speciesUrl) {
                speciesAvatar = Image(uiImage: image)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(alignment: .center) {
                    if let observation = model.observation {
                        ObservationInfoView(width: geo.size.width, fallbackThumbnail: speciesAvatar, observation: observation) { view in
                            navigationController?.pushViewController(view, animated: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
         
                view
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
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationView(occurenceId: DBObservation.sampleData.occurenceId, persistenceController: ObservationPersistenceController(inMemory: true))
    }
}
