//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

extension View {
    func picker() -> some View {
        self
            .overlay(alignment: .center) {
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: 50)
            Rectangle()
                .fill(Color.white)
                .frame(width: 50, height: 2)
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
            }
    }
    
    func trackingToggle(@Binding userTrackingMode: MapUserTrackingMode, authorizationStatus: CLAuthorizationStatus?) -> some View {
        self
            .overlay(alignment: .topTrailing) {
                if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
                    RoundedRectangle(cornerRadius: .defaultPadding)
                        .fill(.white)
                        .frame(width: .fabSize, height: .fabSize)
                        .shadow(radius: .halfPadding)
                        .padding(.defaultPadding)
                        .overlay {
                            switch(userTrackingMode) {
                            case .follow:
                                Image(systemName: "location.fill")
                                    .padding(.fabIconPadding)
                            default:
                                Image(systemName: "location")
                                    .padding(.fabIconPadding)
                            }
                        }
                        .onTapGesture {
                            switch(userTrackingMode) {
                            case .none:
                                if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
                                    userTrackingMode = .follow
                                }
                            default:
                                userTrackingMode = .none
                            }
                        }
                }
            }
    }
}
