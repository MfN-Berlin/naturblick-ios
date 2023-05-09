//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct PermissionInfoView: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        BaseView {
            VStack {
                Spacer()
                
                HStack {
                    Image("photo24")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 32)
                        .foregroundColor(.onSecondaryHighEmphasis)
                    
                    Image(systemName: "camera.macro")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 32)
                        .foregroundColor(.onSecondaryHighEmphasis)
                }
                
                Text("Wenn du dieses Feature nutzen möchtest braucht Naturblick die Berechtigungen zum Benutzen deiner Kamera und zum Speichern der Bilder in deinen Fotos. Gehe in die Einstellungen und erlaube es.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.onSecondaryHighEmphasis)
                
                Spacer()
                
                VStack {
                    Button {
                        if let url = URL(string:UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { _ in print("[ completed ]") })
                            }
                        }
                    } label: {
                        Text("Zu den Einstellungen")
                            .padding()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.onSecondaryButtonPrimary)
                    .clipShape(Capsule())
                    .padding()
                    
                    Button {
                        isPresented = false
                    } label: {
                        Text("Vielleicht später")
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
    }

}

struct PermissionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionInfoView(isPresented: .constant(true))
    }
}
