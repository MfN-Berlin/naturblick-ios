//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

enum HttpError: Error {
    case networkError
    case serverError(statusCode: Int, data: String)
    case clientError(statusCode: Int)
}

extension HttpError {
    var localizedDescription: String {
        switch(self) {
        case .networkError:
            return "Can not connect to server, please check your connectivity."
        case .serverError:
            return "The server responded with an error, please try again later."
        case .clientError:
            return "The server responded with an error, please try again later."
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
    
    func alertHttpError<A, M>(isPresented: Binding<Bool>, error: HttpError?, @ViewBuilder actions: (HttpError) -> A, @ViewBuilder message: (HttpError) -> M) -> some View where A : View, M : View {
        return self.alert("Error", isPresented: isPresented, presenting: error, actions: actions, message: message)
    }
    
}
