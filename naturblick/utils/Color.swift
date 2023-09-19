import SwiftUI

extension Color {
    
    static let onFeatureButtonPrimary = Color("On_Feature.Button_Primary")
    static let onFeatureButtonSecondary = Color("On_Feature.Button_Secondary")
    static let onFeatureDisabled = Color("On_Feature.Disabled")
    static let onFeatureHighEmphasis = Color("On_Feature.High_Emphasis")
    static let onFeatureLowEmphasis = Color("On_Feature.Low_Emphasis")
    static let onFeatureMediumEmphasis = Color("On_Feature.Medium_Emphasis")
    static let onFeatureSignalHigh = Color("On_Feature.Signal_High")
    static let onFeatureSignalLow = Color("On_Feature.Signal_Low")
    static let onFeaturetag = Color("On_Feature.tag")
    
    static let onPrimaryButtonPrimary = Color("On_Primary.Button_Primary")
    static let onPrimaryButtonSecondary = Color("On_Primary.Button_Secondary")
    static let onPrimaryDisabled = Color("On_Primary.Disabled")
    static let onPrimaryHighEmphasis = Color("On_Primary.High_Emphasis")
    static let onPrimaryLowEmphasis = Color("On_Primary.Low_Emphasis")
    static let onPrimaryMediumEmphasis = Color("On_Primary.Medium_Emphasis")
    static let onPrimaryMinimumEmphasis = Color("On_Primary.Minimum_Emphasis")
    static let onPrimarySignalHigh = Color("On_Primary.Signal_High")
    static let onPrimarySignalLow = Color("On_Primary.Signal_Low")
    static let onPrimarytag = Color("On_Primary.tag")
    
    static let onSecondaryButtonPrimary = Color("On_Secondary.Button_Primary")
    static let onSecondaryButtonSecondary = Color("On_Secondary.Button_Secondary")
    static let onSecondaryDisabled = Color("On_Secondary.Disabled")
    static let onSecondaryHighEmphasis = Color("On_Secondary.High_Emphasis")
    static let onSecondaryLowEmphasis = Color("On_Secondary.Low_Emphasis")
    static let onSecondaryMediumEmphasis = Color("On_Secondary.Medium_Emphasis")
    static let onSecondaryMinimumEmphasis = Color("On_Secondary.Minimum_Emphasis")
    static let onSecondarySignalHigh = Color("On_Secondary.Signal_High")
    static let onSecondarySignalLow = Color("On_Secondary.Signal_Low")
    static let onSecondarySignalMedium = Color("On_Secondary.Signal_Medium")
    static let onSecondarytag = Color("On_Secondary.tag")
    static let onSecondarywarning = Color("On_Secondary.warning")
    
    static let primaryColor = Color("Primary")
    static let primaryHomeColor = Color("PrimaryHome")
    static let secondaryColor = Color("Secondary")
    static let tertiaryColor = Color("tertiary")
    static let backdropColor = Color("backdrop")
    static let featureColor = Color("Feature")
    
    static let onImageSignalLow = Color.black.opacity(0.3)
    static let whiteOpacity10 = Color.white.opacity(0.4)
    static let whiteOpacity60 = Color.white.opacity(0.8)
    static let shadowBlackOpacity10 = Color.black.opacity(0.1)
    static let shadowBlackOpacity5 = Color.black.opacity(0.05)
    static let shadowGreyOpacity5 = Color("shadowGreyOpacity5")


}

extension UIColor {
    static var onPrimaryButtonSecondary: UIColor {
        return UIColor { (traits) -> UIColor in
            traits.userInterfaceStyle == .dark ?
                UIColor(red: 0.063, green: 0.247, blue: 0.373, alpha: 1.000) :
                UIColor(red: 0.055, green: 0.220, blue: 0.333, alpha: 1.000)
        }
    }

    static var onPrimaryHighEmphasis: UIColor {
        return UIColor { (traits) -> UIColor in
            traits.userInterfaceStyle == .dark ?
                UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000) :
                UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        }
    }
    
    static var onSecondaryHighEmphasis: UIColor {
        return UIColor { (traits) -> UIColor in
            traits.userInterfaceStyle == .dark ?
            UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000) :
            UIColor(red: 0.070, green: 0.273, blue: 0.414, alpha: 1.000)
        }
    }
    
    static let primaryHome = UIColor(red: 0.071, green: 0.275, blue: 0.416, alpha: 1.000)
    
    static var secondary: UIColor {
        return UIColor { (traits) -> UIColor in
            traits.userInterfaceStyle == .dark ?
            UIColor(red: 0.051, green: 0.192, blue: 0.290, alpha: 1.000) :
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.000)
        }
    }
}
