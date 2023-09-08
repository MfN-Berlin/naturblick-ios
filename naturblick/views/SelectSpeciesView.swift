//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


struct SelectSpeciesView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let client = BackendClient()
    @ObservedObject var createFlow: CreateFlowViewModel
    let thumbnail: NBImage
    @State var showInfo: SpeciesInfo? = nil
    @StateObject var model: SelectSpeciesViewModel = SelectSpeciesViewModel()
    @StateObject private var errorHandler = HttpErrorViewModel()

    func openSpeciesInfo(species: SpeciesListItem, image: Image) {
        let info = SpeciesInfoViewController(info: SpeciesInfo(species: species, avatar: image), createFlow: createFlow)
        withNavigation { navigation in
            navigation.pushViewController(info, animated: true)
        }
    }
    
    func identify() {
        Task {
            do {
                try await client.upload(image: thumbnail)
                createFlow.updateResult(result: try await client.imageId(mediaId: thumbnail.id.uuidString))
            } catch {
                let _ = errorHandler.handle(error)
            }
        }
    }
    
    var body: some View {
        VStack {
            Image(uiImage: thumbnail.image)
                .resizable()
                .scaledToFit()
            if let rs = createFlow.data.image.result {
                VStack(alignment: .leading) {
                    ForEach(model.speciesResults, id: \.0.id) { (result, item) in
                        if let url = item.url {
                            // When used, AsyncImage has to be the outermost element
                            // or it will not properly load in List
                            AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                                SpeciesResultView(result: result, species: item, avatar: image)
                                    .onTapGesture {
                                        openSpeciesInfo(species: item, image: image)
                                    }
                            } placeholder: {
                                SpeciesResultView(result: result, species: item, avatar: Image("placeholder"))
                                    .onTapGesture {
                                        openSpeciesInfo(species: item, image: Image("placeholder"))
                                    }
                            }
                        } else {
                            SpeciesResultView(result: result, species: item, avatar: Image("placeholder"))
                                .onTapGesture {
                                    openSpeciesInfo(species: item, image: Image("placeholder"))
                                }
                        }
                    }
                }
                .onAppear {
                    model.resolveSpecies(results: rs)
                }
            } else {
                Text("Loading ...")
                    .onAppear {
                        identify()
                    }
            }
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error) { details in
            Button("Retry") {
                identify()
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
