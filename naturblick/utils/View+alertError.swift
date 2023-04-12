//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

extension View {
    func alertHttpError(isPresented: Binding<Bool>, error: HttpError?) -> some View {
        return self.alert("Http error", isPresented: isPresented, presenting: error) { details in
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
