//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct LocationRequestView: View {
    
    @Environment(\.dismiss) var dismiss
    let locationManager = LocationManager.shared
    
    var body: some View {
        BaseView {
            VStack {
                Spacer()
                
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)
                    .foregroundColor(.onSecondaryHighEmphasis)
                
                Text("Would you like to attach a location to your observation?")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.onSecondaryHighEmphasis)
                
                Spacer()
                
                VStack {
                    Button {
                        LocationManager.shared.requestLocation()
                    } label: {
                        Text("Allow location")
                            .button()
                            .padding()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.onSecondaryButtonPrimary)
                    .clipShape(Capsule())
                    .padding()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Maybe later")
                            .button()
                            .padding()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.onSecondaryButtonSecondary)
                    .clipShape(Capsule())
                    .padding()
                }
                .padding()
            }
        }
        .padding()
        .onReceive(locationManager.$permissionStatus) { status in
            switch status {
            case .notDetermined:
                break
            case .restricted:
                dismiss()
            case .denied:
                dismiss()
            case .authorizedAlways:
                dismiss()
            case .authorizedWhenInUse:
                dismiss()
            case .none:
                break
            @unknown default:
                break
            }
        }
    }
}

struct LocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
    }
}
