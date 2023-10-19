//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

enum HttpError: Error {
    case networkError
    case serverError(statusCode: Int, data: String)
    case clientError(statusCode: Int)
    case loggedOut
}

extension HttpError {
    var localizedDescription: String {
        switch(self) {
        case .networkError:
            return String(localized: "cannot_connect")
        case .serverError:
            return String(localized: "responded_error")
        case .clientError:
            return String(localized: "responded_error")
        case .loggedOut:
            return String(localized: "logged_out_error")
        }
    }
}

extension View {
    func alertHttpError(isPresented: Binding<Bool>, error: HttpError?) -> some View {
        return self.alertHttpError(isPresented: isPresented, error: error) { details in
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    func alertHttpError<A>(isPresented: Binding<Bool>, error: HttpError?, @ViewBuilder actions: (HttpError) -> A) -> some View where A : View {
        return self.alertHttpError(isPresented: isPresented, error: error, actions: actions) { error in
            Text(error.localizedDescription)
        }
    }
    
    func alertHttpError<A, M>(isPresented: Binding<Bool>, error: HttpError?, @ViewBuilder actions: (HttpError) -> A, @ViewBuilder message: (HttpError) -> M) -> some View where A : View, M : View {
        return self.alert(String(localized: "error"), isPresented: isPresented, presenting: error, actions: actions, message: message)
    }
    
}
