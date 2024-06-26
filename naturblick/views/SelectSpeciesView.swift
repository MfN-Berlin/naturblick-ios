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
        let info = SpeciesInfoView(selectionFlow: true, species: species, flow: flow).setUpViewController()
        viewController?.present(PopAwareNavigationController(rootViewController: info), animated: true)
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
                        .accessibilityHidden(true)
                }
                .overlay(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: .defaultPadding) {
                        if let results
                            = model.speciesResults {
                            Text("suggestions")
                                .headline4()
                                .padding([.top])
                            Text(flow.isImage() ? "image_autoid_infotext" : "sound_autoid_infotext")
                                .body2()
                            ForEach(results.indices, id: \.self) { index in
                                SpeciesResultView(result: results[index].0, species: results[index].1)
                                    .listRowInsets(.nbInsets)
                                    .onTapGesture {
                                        openSpeciesInfo(species: results[index].1)
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityAction {
                                        openSpeciesInfo(species: results[index].1)
                                    }
                                    .accessibilitySortPriority(Double(4 - index))
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
                            .accessibilityElement(children: .combine)
                            .accessibilityAction {
                                presentAlternativesDialog = true
                            }
                            .accessibilitySortPriority(1)
                        } else {
                            ProgressView {
                                Text("identifying_species")
                                    .headline6(color: .onSecondaryMediumEmphasis)
                            }
                            .progressViewStyle(CircularProgressViewStyle(tint: .onSecondaryHighEmphasis))
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
                    if !UIAccessibility.isVoiceOverRunning {
                        Button(flow.isImage() ? "crop_again" : "crop_sound_again") {
                            navigationController?.popViewController(animated: true)
                        }
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
