//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

class ObservationViewController: HostingController<ObservationView> {
    let persistenceController: ObservationPersistenceController
    let model: ObservationViewModel

    init(occurenceId: UUID, persistenceController: ObservationPersistenceController) {
        self.persistenceController = persistenceController
        self.model = ObservationViewModel(viewObservation: occurenceId, persistenceController: persistenceController)
        super.init(rootView: ObservationView(occurenceId: occurenceId, persistenceController: persistenceController, model: model))
    }
}

struct ObservationView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let client = BackendClient()
    var hideNavigationBarShadow: Bool = true
    @State var speciesAvatar: Image = Image("placeholder")
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var model: ObservationViewModel
    let occurenceId: UUID
    
    init(occurenceId: UUID, persistenceController: ObservationPersistenceController, model: ObservationViewModel) {
        self.occurenceId = occurenceId
        self.persistenceController = persistenceController
        self.model = model
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        let deleteButton = UIBarButtonItem(image: UIImage(named: "trash_24"), primaryAction: UIAction {_ in
            model.delete = true
        })
        deleteButton.tintColor = UIColor(Color.onSecondarywarning)
        let editButton = UIBarButtonItem(title: String(localized: "edit"), primaryAction: UIAction {_ in
            if let observation = persistenceController.observations.first(where: {$0.observation.occurenceId == occurenceId}) {
                let view = EditObservationViewController(observation: observation, persistenceController: persistenceController)
                let navigation = InSheetPopAwareNavigationController(rootViewController: view)
                viewController?.present(navigation, animated: true)
            }
        })
        item.rightBarButtonItems = [editButton, deleteButton]
    }
    
    var view: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                speciesAvatar
                    .avatar()
                    .padding(.trailing, .defaultPadding)
                
                VStack(alignment: .leading, spacing: .zero) {
                    Text("species")
                        .caption(color: .onSecondarySignalLow)
                    if let species = model.observation?.species {
                        Text(species.speciesName ?? species.sciname)
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    } else {
                        Text("unknown_species")
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    }
                }
                Spacer()
                if model.observation?.species != nil {
                    ChevronView(color: .onSecondarySignalLow)
                }
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
                if model.observation?.observation.coords != nil {
                    ChevronView(color: .onSecondarySignalLow)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if model.observation?.observation.coords != nil {
                    navigationController?.pushViewController(ObservationListViewController(persistenceController: persistenceController, showObservation: model.observation), animated: true)
                }
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
                VStack(alignment: .center, spacing: .zero) {
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
        .confirmationDialog("delete_question", isPresented: $model.delete, titleVisibility: .visible) {
            Button("delete", role: .destructive) {
                do {
                    try persistenceController.delete(occurenceId: occurenceId)
                    navigationController?.popViewController(animated: true)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        } message: {
            Text("delete_question_message")
        }
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = ObservationPersistenceController(inMemory: true)
        ObservationView(occurenceId: DBObservation.sampleData.occurenceId, persistenceController: persistenceController, model: ObservationViewModel(viewObservation: DBObservation.sampleData.occurenceId, persistenceController: persistenceController))
    }
}
