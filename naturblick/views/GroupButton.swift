//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct GroupButton: View {
    
    let group: Group
    
    var body: some View {
        NavigationLink(destination: HomeView()) {   // SpeciesView(group: group) 
            VStack {
                Image(systemName: "questionmark").resizable()
                    .clipShape(Capsule())
                    .scaledToFill()
                Text(group.gerName)
                    .multilineTextAlignment(TextAlignment.center)
                    .foregroundColor(.white)
            }
        }
    }
}

struct GroupButton_Previews: PreviewProvider {
    static var previews: some View {
        GroupButton(group: Group.groups[0])
    }
}
