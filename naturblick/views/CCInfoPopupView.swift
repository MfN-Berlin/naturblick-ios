//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct CCInfoPopupView : View {
    
    @Binding var present: Bool
    
    private func textAndSourceAsLink(source: String) -> String {
        return String(localized: "source \(source)")
    }
    
    private func licenceToLink(licence: String) -> String {

        func sa(licence: String) -> String {
            if (licence.contains("sa")) {
                return "-sa"
            }
            return ""
        }

        func version(licence: String) -> String {
            if (licence.contains("1.0")) {
                return  "1.0"
            } else if (licence.contains("2.0")) {
                return  "2.0"
            } else if (licence.contains("2.5")) {
                return  "2.5"
            } else if (licence.contains("3.0")) {
                return  "3.0"
            } else if (licence.contains("4.0")) {
                return  "4.0"
            }
            return ""
        }

        let l = licence.lowercased()
        if (l.contains("cc0") || l.contains("cc 0")) {
            return "[\(licence)](https://creativecommons.org/publicdomain/zero/1.0/)"
        } else if (l.contains("cc") && l.contains("by")) {
            return "[\(licence)](https://creativecommons.org/licenses/by\(sa(licence: l))/\(version(licence: l))/)"
        }
        return "(\(licence))"
    }
    
    let imageSource: String
    let imageOwner: String
    let imageLicense: String
    
    var body: some View {
        VStack(spacing: .defaultPadding) {
            // Links build by string interpolation must be wrapped into AttributedString
            if let txt = try? AttributedString(markdown: "\(textAndSourceAsLink(source: imageSource)) (\(licenceToLink(licence: imageLicense))) \(imageOwner)") {
                Text(txt)
            }
        
            Button("Close") {
                present = false
            }
            .foregroundColor(.onSecondaryHighEmphasis)
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .padding()
        .background(RoundedRectangle(cornerRadius: .smallCornerRadius)
            .fill(Color.secondaryColor)
            .nbShadow())
    }
}

struct CCInfoPopupView_Preview : PreviewProvider {
    static var previews: some View {
        CCInfoPopupView(present: .constant(true), imageSource: "https://commons.wikimedia.org/wiki/File:FooBar.jpg", imageOwner: "John Jana Josen", imageLicense: "CC BY-SA 3.0")
    }
}
