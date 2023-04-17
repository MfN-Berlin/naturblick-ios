//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.
import SwiftUI

struct ColorTestView: View {
    
    func showCase(color: Color, text: String) -> some View {
        HStack {
            Text(text).foregroundColor(color)
            Rectangle().frame(width: 25, height: 25).foregroundColor(color)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // primary
                ZStack {
                    Color.primaryColor
                    VStack {
                        VStack {
                            showCase(color: .onPrimaryHighEmphasis, text: "onPrimaryHighEmphasis")
                            showCase(color: .onPrimaryButtonPrimary, text: "onPrimaryButtonPrimary")
                            showCase(color: .onPrimaryButtonSecondary, text: "onPrimaryButtonSecondary")
                            showCase(color: .onPrimaryDisabled, text: "onPrimaryDisabled")
                            showCase(color: .onPrimaryHighEmphasis, text: "onPrimaryHighEmphasis")
                            showCase(color: .onPrimaryLowEmphasis, text: "onPrimaryLowEmphasis")
                            showCase(color: .onPrimaryMediumEmphasis, text: "onPrimaryMediumEmphasis")
                            showCase(color: .onPrimaryMinimumEmphasis, text: "onPrimaryMinimumEmphasis")
                            showCase(color: .onPrimarySignalHigh, text: "onPrimarySignalHigh")
                            showCase(color: .onPrimarySignalLow, text: "onPrimarySignalLow")
                        }
                        VStack {
                            showCase(color: .onPrimarytag, text: "onPrimarytag")
                        }
                    }
                }
                
                // secondary
                ZStack {
                    Color.secondaryColor
                    VStack {
                        VStack {
                            showCase(color: .onSecondaryButtonPrimary, text: "onSecondaryButtonPrimary")
                            showCase(color: .onSecondaryButtonSecondary, text: "onSecondaryButtonSecondary")
                            showCase(color: .onSecondaryDisabled, text: "onSecondaryDisabled")
                            showCase(color: .onSecondaryHighEmphasis, text: "onSecondaryHighEmphasis")
                            showCase(color: .onSecondaryLowEmphasis, text: "onSecondaryLowEmphasis")
                            showCase(color: .onSecondaryMediumEmphasis, text: "onSecondaryMediumEmphasis")
                            showCase(color: .onSecondaryMinimumEmphasis, text: "onSecondaryMinimumEmphasis")
                            showCase(color: .onSecondarySignalHigh, text: "onSecondarySignalHigh")
                            showCase(color: .onSecondarySignalLow, text: "onSecondarySignalLow")
                            showCase(color: .onSecondarySignalMedium, text: "onSecondarySignalMedium")
                        }
                        VStack {
                            showCase(color: .onSecondarytag, text: "onSecondarytag")
                            showCase(color: .onSecondarywarning, text: "onSecondarywarning")
                        }
                    }
                }
                
                // Feature
                ZStack {
                    Color.featureColor
                    VStack {
                        showCase(color: .onFeatureButtonPrimary, text: "onFeatureButtonPrimary")
                        showCase(color: .onFeatureButtonSecondary, text: "onFeatureButtonSecondary")
                        showCase(color: .onFeatureDisabled, text: "onFeatureDisabled")
                        showCase(color: .onFeatureHighEmphasis, text: "onFeatureHighEmphasis")
                        showCase(color: .onFeatureLowEmphasis, text: "onFeatureLowEmphasis")
                        showCase(color: .onFeatureMediumEmphasis, text: "onFeatureMediumEmphasis")
                        showCase(color: .onFeatureSignalHigh, text: "onFeatureSignalHigh")
                        showCase(color: .onFeatureSignalLow, text: "onFeatureSignalLow")
                        showCase(color: .onFeaturetag, text: "onFeaturetag")
                    }
                }
                
                // Others
                ZStack {
                    Color.tertiaryColor
                    showCase(color: .onPrimaryHighEmphasis, text: "background is Tertiary")
                }
                ZStack {
                    Color.backdropColor
                    showCase(color: .onPrimaryHighEmphasis, text: "background is backdrop")
                }
            }
        }
    }
}
struct ColorTestView_Previews: PreviewProvider {
    static var previews: some View {
        ColorTestView()
    }
}
