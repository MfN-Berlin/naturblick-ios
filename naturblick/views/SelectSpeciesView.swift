//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage
import BottomSheet

struct SelectSpeciesView<Flow>: NavigatableView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        "Choose species"
    }
    
    @ObservedObject var flow: Flow
    let thumbnail: NBImage
    @State var showInfo: SpeciesListItem? = nil
    @State private var sheetPosition: BottomSheetPosition = .dynamic
    @State private var presentAlternativesDialog: Bool = false
    @StateObject var model: SelectSpeciesViewModel = SelectSpeciesViewModel()
    @StateObject private var errorHandler = HttpErrorViewModel()
    
    func openSpeciesInfo(species: SpeciesListItem) {
        let info = SpeciesInfoView(species: species, flow: flow).setUpViewController()
        withNavigation { navigation in
            navigation.pushViewController(info, animated: true)
        }
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
            VStack {
                Image(uiImage: thumbnail.image)
                    .resizable()
                    .frame(width: geo.size.width, height: geo.size.width)
                Spacer()
            }
            .bottomSheet(bottomSheetPosition: $sheetPosition, switchablePositions: [.dynamic, .dynamicBottom]) {
                VStack {
                    
                    if let results = model.speciesResults {
                        Text("The list suggests wild plants found in the city. The suggestions are created by comparing photos of over 2000 species. The closer the score is to 100%, the more likely the match is.")
                            .font(.nbBody2)
                            .foregroundColor(.onSecondaryMediumEmphasis)
                            .padding(.bottom, .defaultPadding)
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
                                Text("None of the above")
                                    .subtitle1()
                                Spacer()
                        }
                        .contentShape(Rectangle())
                        .listRowInsets(.nbInsets)
                        .onTapGesture {
                            presentAlternativesDialog = true
                        }
                    } else {
                        ProgressView {
                            Text("Identifying species")
                                .font(.nbButton)
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
                .frame(minHeight: geo.size.height - geo.size.width + geo.safeAreaInsets.bottom)
                .padding(.horizontal, .defaultPadding)
                .padding(.bottom, geo.safeAreaInsets.bottom)
            }
            .customBackground(
                RoundedRectangle(cornerRadius: .largeCornerRadius)
                    .fill(Color.secondaryColor)
                    .nbShadow()
            )
            .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error) { details in
                Button("Try again") {
                    identify()
                }
                Button("Browse species") {
                    
                }
                Button("Save as unknown species") {
                    flow.selectSpecies(species: nil)
                }
            }
            .alert("Do you want to identify the species in another way?", isPresented: $presentAlternativesDialog) {
                Button("Use another part of the image") {
                    navigationController?.popViewController(animated: true)
                }
                Button("Browse species") {
                    print("Browse species")
                }
                Button("Save as unknown species") {
                    flow.selectSpecies(species: nil)
                }
                Button("Cancel", role: .cancel) {
                }
            }
        }
       
    }
}
