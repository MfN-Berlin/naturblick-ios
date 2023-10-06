//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct StaticBottomSheetView<MainContent: View, SheetContent: View>: View {
    let main: () -> MainContent
    let sheet: () -> SheetContent
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                main()
                    .frame(maxHeight: .infinity)
                VStack {
                    sheet()
                }
                .padding(.defaultPadding)
                .padding(.bottom, geo.safeAreaInsets.bottom)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: .largeCornerRadius)
                        .fill(Color.secondaryColor)
                        .nbShadow()
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct StaticBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        StaticBottomSheetView {
            Text("main")
        } sheet: {
            Text("sheet")
        }
    }
}
