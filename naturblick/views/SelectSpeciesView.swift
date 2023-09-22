//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage

struct SelectSpeciesView<Flow>: NavigatableView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        "Choose species"
    }
    
    @ObservedObject var flow: Flow
    let thumbnail: NBImage
    @State var showInfo: SpeciesListItem? = nil
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
                try await flow.identify()
            } catch {
                let _ = errorHandler.handle(error)
            }
        }
    }
    
    func urlRequest(species: SpeciesListItem) -> URLRequest? {
        if let urlstr = species.url, let url = URL(string: Configuration.strapiUrl + urlstr) {
            return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack {
            Image(uiImage: thumbnail.image)
                .resizable()
                .scaledToFit()
            if let rs = flow.result {
                VStack(alignment: .leading) {
                    ForEach(model.speciesResults, id: \.0.id) { (result, item) in
                        CachedAsyncImage(urlRequest: urlRequest(species: item)) { image in
                            SpeciesResultView(result: result, species: item, avatar: image)
                                .onTapGesture {
                                    openSpeciesInfo(species: item)
                                }
                        } placeholder: {
                            SpeciesResultView(result: result, species: item, avatar: Image("placeholder"))
                                .onTapGesture {
                                    openSpeciesInfo(species: item)
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
