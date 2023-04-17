//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BaseView<Content : View>: View {
    
    let navTitle: String?
    let oneColor: Bool
    @ViewBuilder let content: () -> Content
    
    var secondaryColor: Color {
        if (oneColor) {
            return Color.primaryColor
        } else {
            return Color.secondaryColor
        }
    }
    
    var onSecondaryHighEmphasis: Color {
        if (oneColor) {
            return Color.onPrimaryHighEmphasis
        } else {
            return Color.onSecondaryHighEmphasis
        }
    }
    
    var body: some View {
        ZStack {
            Color.primaryColor.edgesIgnoringSafeArea([.top])
            let view = ZStack {
                secondaryColor
                content()
            }.edgesIgnoringSafeArea([.bottom])
            if let n = navTitle {
                view.navigationTitle(n)
            } else {
                view
            }
        }
    }
    
    init(navTitle: String? = nil, oneColor: Bool = false, content: @escaping () -> Content) {
        UINavigationBar.appearance().largeTitleTextAttributes = [.backgroundColor: UIColor(.primaryColor)]
        UINavigationBar.appearance().titleTextAttributes = [.backgroundColor: UIColor(.primaryColor)]
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(.onPrimaryHighEmphasis)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(.onPrimaryHighEmphasis)]
        
        self.navTitle = navTitle
        self.content = content
        self.oneColor = oneColor
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BaseView(navTitle: "TestView", oneColor: false, content: {
                Text("Hello Dude")
                    .foregroundColor(.onSecondaryHighEmphasis)
            })
        }
    }
}
