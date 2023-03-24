//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct SpeciesListItemView: View {
    let species: Species
    var body: some View {
        Text(species.sciname)
    }
}

struct SpeciesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListItemView(species: Species.sampleData)
    }
}
