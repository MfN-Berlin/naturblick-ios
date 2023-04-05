//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct ColorTestView: View {
    
    var body: some View {
        VStack {
            Text(" === Primary ===") 
            VStack {
                Text("onPrimaryHighEmphasis")
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimaryMediumEmphasis").foregroundColor(.onPrimaryMediumEmphasis).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimaryLowEmphasis").foregroundColor(.onPrimaryLowEmphasis).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimaryMinimumEmphasis").foregroundColor(.onPrimaryMinimumEmphasis).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimaryDisabled").foregroundColor(.onPrimaryDisabled).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimarySignalLow").foregroundColor(.onPrimarySignalLow).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimarySignalHigh").foregroundColor(.onPrimarySignalHigh).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimaryButtonPrimary").foregroundColor(.onPrimaryButtonPrimary).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimaryButtonSecondary").foregroundColor(.onPrimaryButtonSecondary).background(Rectangle().foregroundColor(.nbPrimary))
                Text("onPrimaryTag")
                    .foregroundColor(.onPrimaryTag)
                    .background(
                        Rectangle().foregroundColor(.nbPrimary))
            }
            Text(" === Secondary ===")
            VStack {
                Text("onSecondaryHighEmphasis").foregroundColor(.onSecondaryHighEmphasis).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondaryMediumEmphasis").foregroundColor(.onSecondaryMediumEmphasis).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondaryLowEmphasis").foregroundColor(.onSecondaryLowEmphasis).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondaryMinimumEmphasis").foregroundColor(.onSecondaryMinimumEmphasis).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondaryDisabled").foregroundColor(.onSecondaryDisabled).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondarySignalLow").foregroundColor(.onSecondarySignalLow).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondarySignalMedium").foregroundColor(.onSecondarySignalMedium).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondarySignalHigh").foregroundColor(.onSecondarySignalHigh).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondaryButtonPrimary").foregroundColor(.onSecondaryButtonPrimary).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondaryButtonSecondary").foregroundColor(.onSecondaryButtonSecondary).background(Rectangle().foregroundColor(.nbSecondary))
            }
            VStack {
                Text("onSecondaryTag").foregroundColor(.onSecondaryTag).background(Rectangle().foregroundColor(.nbSecondary))
                Text("onSecondaryWarning").foregroundColor(.onSecondaryWarning).background(Rectangle().foregroundColor(.nbSecondary))
            }
            // Feature
            Text(" === Feature ===")
            VStack {
                Text("onFeatureHighEmphasis")
                    .foregroundColor(.onFeatureHighEmphasis)
                    .background(Rectangle().foregroundColor(.nbFeature))
                Text("onFeatureMediumEmphasis").foregroundColor(.onFeatureMediumEmphasis).background(Rectangle().foregroundColor(.nbFeature))
                Text("onFeatureLowEmphasis").foregroundColor(.onFeatureLowEmphasis).background(Rectangle().foregroundColor(.nbFeature))
   
                Text("onFeatureDisabled").foregroundColor(.onFeatureDisabled).background(Rectangle().foregroundColor(.nbFeature))
                Text("onFeatureSignalLow").foregroundColor(.onFeatureSignalLow).background(Rectangle().foregroundColor(.nbFeature))
                Text("onFeatureSignalHigh").foregroundColor(.onFeatureSignalHigh).background(Rectangle().foregroundColor(.nbFeature))
                Text("onFeatureButtonPrimary").foregroundColor(.onFeatureButtonPrimary).background(Rectangle().foregroundColor(.nbFeature))
                Text("onFeatureButtonSecondary").foregroundColor(.onFeatureButtonSecondary).background(Rectangle().foregroundColor(.nbFeature))
                Text("onFeatureTag")
                    .foregroundColor(.onFeatureTag)
                    .background(
                        Rectangle().foregroundColor(.nbFeature))
            }
        }
    }
}


struct ColorTestView_Previews: PreviewProvider {
    static var previews: some View {
        ColorTestView()
    }
}



