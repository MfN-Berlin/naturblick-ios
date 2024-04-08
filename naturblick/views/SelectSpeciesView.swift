//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage

struct SelectSpeciesView<Flow>: NavigatableView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? = String(localized: "results")

    @ObservedObject var flow: Flow
    let thumbnail: NBThumbnail
    @State var showInfo: SpeciesListItem? = nil
    @State private var presentAlternativesDialog: Bool = false
    @StateObject var model: SelectSpeciesViewModel = SelectSpeciesViewModel()
    @StateObject private var errorHandler = HttpErrorViewModel()
    
    func openSpeciesInfo(species: SpeciesListItem) {
        let info = SpeciesInfoView(species: species, flow: flow).setUpViewController()
        viewController?.present(InSheetPopAwareNavigationController(rootViewController: info), animated: true)
    }
    
    func identify() {
        Task {
            do {
                model.resolveSpecies(results: try await flow.identify())
            } catch {
                let _ = errorHandler.handle(error)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    Image(uiImage: thumbnail.image)
                        .resizable()
                        .frame(width: geo.size.width, height: geo.size.width)
                }
                .overlay(alignment: .bottom) {
                    VStack(spacing: .defaultPadding) {
                        if let results = model.speciesResults {
                            Text(flow.isImage() ? "image_autoid_infotext" : "sound_autoid_infotext")
                                .body2()
                            ForEach(results, id: \.0.id) { (result, item) in
                                SpeciesResultView(result: result, species: item)
                                    .listRowInsets(.nbInsets)
                                    .onTapGesture {
                                        openSpeciesInfo(species: item)
                                    }
                                Divider()
                            }
                            HStack(alignment: .center) {
                                Image("unknown_species")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: .avatarSize, height: .avatarSize)
                                    .padding(.trailing, .defaultPadding)
                                    .foregroundColor(.onSecondaryHighEmphasis)
                                Text("none_of_the_options")
                                    .subtitle1()
                                Spacer()
                                ChevronView(color: .onPrimarySignalLow)
                            }
                            .contentShape(Rectangle())
                            .listRowInsets(.nbInsets)
                            .onTapGesture {
                                presentAlternativesDialog = true
                            }
                        } else {
                            ProgressView {
                                Text("identifying_species")
                                    .button()
                                    .foregroundColor(.onSecondaryMediumEmphasis)
                            }
                            .progressViewStyle(.circular)
                            .foregroundColor(.onSecondaryHighEmphasis)
                            .controlSize(.large)
                            .onAppear {
                                identify()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: geo.size.height - geo.size.width + geo.safeAreaInsets.bottom)
                    .padding(.defaultPadding)
                    .padding(.bottom, geo.safeAreaInsets.bottom)
                    .background(
                        RoundedRectangle(cornerRadius: .largeCornerRadius)
                            .fill(Color.secondaryColor)
                            .nbShadow()
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error) { details in
                    Button("try_again") {
                        identify()
                    }
                    Button("browse_species") {
                        flow.searchSpecies()
                    }
                    Button("save_unknown") {
                        flow.selectSpecies(species: nil)
                    }
                }
                .alert("other_identification", isPresented: $presentAlternativesDialog) {
                    Button(flow.isImage() ? "crop_again" : "crop_sound_again") {
                        navigationController?.popViewController(animated: true)
                    }
                    Button("browse_species") {
                        flow.searchSpecies()
                    }
                    Button("save_unknown") {
                        flow.selectSpecies(species: nil)
                    }
                    Button("cancel", role: .cancel) {
                    }
                }
        }
    }
}
