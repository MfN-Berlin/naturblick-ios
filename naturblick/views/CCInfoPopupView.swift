//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct CCInfoPopupView : View {
    
    private func textAndSourceAsLink(source: String) -> String {
        return "[Source](\(source)/)"
    }
    
    private func licenseToLink(license: String) -> String {

        func sa(license: String) -> String {
            if (license.contains("sa")) {
                return "-sa"
            }
            return ""
        }

        func version(license: String) -> String {
            if (license.contains("1.0")) {
                return  "1.0"
            } else if (license.contains("2.0")) {
                return  "2.0"
            } else if (license.contains("2.5")) {
                return  "2.5"
            } else if (license.contains("3.0")) {
                return  "3.0"
            } else if (license.contains("4.0")) {
                return  "4.0"
            }
            return ""
        }

        let l = license.lowercased()
        if (l.contains("cc0") || l.contains("cc 0")) {
            return "[\(license)](https://creativecommons.org/publicdomain/zero/1.0/)"
        } else if (l.contains("cc") && l.contains("by")) {
            return "[\(license)](https://creativecommons.org/licenses/by\(sa(license: l))/\(version(license: l))/)"
        }
        return "(\(license))"
    }
    
    let imageSource: String
    let imageOwner: String
    let imageLicense: String
    
    var body: some View {
        VStack {
            // Links build by string interpolation must be wrapped into AttributedString
            if let txt = try? AttributedString(markdown: "\(textAndSourceAsLink(source: imageSource)) (\(licenseToLink(license: imageLicense))) \(imageOwner)") {
                Text(txt)
            }
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .padding()
    }
}

struct CCInfoPopupView_Preview : PreviewProvider {
    static var previews: some View {
        CCInfoPopupView(imageSource: "https://commons.wikimedia.org/wiki/File:FooBar.jpg", imageOwner: "John Jana Josen", imageLicense: "CC BY-SA 3.0")
    }
}
