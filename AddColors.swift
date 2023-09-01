import Foundation

struct Component : Encodable {
    let alphaFloat: String
    let blue: String
    let green: String
    let red: String

    var redFloat: String
    var blueFloat: String
    var greenFloat: String

    private static func toCgFloat(s: String) -> String {
        let decimal = UInt8(s, radix: 16) 
        let opacity: Double = Double(decimal!) / 255
        return String(format: "%.3f", opacity) 
    }

    init(hex: String) {
        let rstart = hex.index(hex.startIndex, offsetBy: 1)
        let rend = hex.index(hex.startIndex, offsetBy: 3)
        let rrange = rstart..<rend
        red = "0x\(hex[rrange].uppercased())"
        redFloat = Component.toCgFloat(s: String(hex[rrange])) 

        let gstart = hex.index(hex.startIndex, offsetBy: 3)
        let gend = hex.index(hex.startIndex, offsetBy: 5)
        let grange = gstart..<gend
        green = "0x\(hex[grange].uppercased())"
        greenFloat = Component.toCgFloat(s: String(hex[grange])) 

        let bstart = hex.index(hex.startIndex, offsetBy: 5)
        let bend = hex.index(hex.startIndex, offsetBy: 7)
        let brange = bstart..<bend
        blue = "0x\(hex[brange].uppercased())"
        blueFloat = Component.toCgFloat(s: String(hex[brange])) 

        if (hex.count == 9) {
            let astart = hex.index(hex.startIndex, offsetBy: 7)
            let aend = hex.index(hex.startIndex, offsetBy: 9)
            let arange = astart..<aend
            alphaFloat = Component.toCgFloat(s: String(hex[arange])) 
        } else {
            alphaFloat = "1.000"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case alpha, blue, green, red
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alphaFloat, forKey: .alpha)
        try container.encode(blue, forKey: .blue)
        try container.encode(green, forKey: .green)
        try container.encode(red, forKey: .red)
    }
}

struct Appearance : Encodable {
     let appearance: String = "luminosity"
     let value: String = "dark"
}

struct Colors : Encodable {
    let color: Color
    let appearances: [Appearance]?
    let idiom: String = "universal"
}

struct Color : Encodable {
    let colorSpace: String = "srgb"
    let components: Component

    enum CodingKeys : String, CodingKey {
        case colorSpace = "color-space"
        case components
    }
}

struct Info : Encodable {
    let author: String = "xcode"
    let version: Int64 = 1
}

struct Token : Encodable {
    let colors: [Colors]
    let info: Info
    let filename: String

    enum CodingKeys : String, CodingKey {
        case colors
        case info
        // name omited, its only for filename 
    }
}

let resources = URL(fileURLWithPath: FileManager().currentDirectoryPath).appendingPathComponent("resources")
let assets = URL(fileURLWithPath: FileManager().currentDirectoryPath).appendingPathComponent("naturblick/Assets.xcassets")
let colorSwift = URL(fileURLWithPath: FileManager().currentDirectoryPath).appendingPathComponent("naturblick/utils/Color.swift")

func loadJson(filename fileName: String) throws -> NSDictionary {
    let data = try Data(contentsOf: resources.appendingPathComponent(fileName))
    return try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
}

func extractColors() -> [String : String] {
    var colors: [String : String] = [:]
    do {
        let base: NSDictionary = try loadJson(filename: "base.json")
        
        for prefix: String in base.allKeys.map({ $0 as! String }) {
            let color = base[prefix] as! NSDictionary
            
            for suffix: String in color.allKeys.map({ $0 as! String }) {
                let value = color[suffix] as! NSDictionary
                colors["\(prefix).\(suffix)"] = value["value"] as? String
            }    
        }    
    } catch {
        print("error:\(error)")
    }
    return colors
}

func formatKey(key: String) -> String {
    return key.replacingOccurrences(of: " ", with: "_")
}

func formatValue(value: String) -> String {
    return value.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
}

func extractColorSet(filename: String) -> [String : String] {
    var colorSet: [String : String] = [:]
    do {
        let json: NSDictionary = try loadJson(filename: filename)
        for prefix: String in json.allKeys.map({ $0 as! String }) {
            let maybeValue = json[prefix] as! NSDictionary
            
            if let value: String = maybeValue["value"] as? String {
                let key = formatKey(key: prefix)
                colorSet[key] = formatValue(value: value)
            } else {
                for suffix: String in maybeValue.allKeys.map({ $0 as! String }) {
                    let value = maybeValue[suffix] as! NSDictionary
                    let key = formatKey(key: "\(prefix).\(suffix)")
                    colorSet[key] = formatValue(value:value["value"] as! String)
                }    
            }
        }
    } catch {
        print("error:\(error)")
    }
    return colorSet
}

@main
enum AddColors {
   
    static func main() async throws {
        
        let colors: [String: String] = extractColors()
        let darkJson: [String: String] = extractColorSet(filename: "dark.json")
        let lightJson: [String: String] = extractColorSet(filename: "global.json")

        let tokens: [Token] = darkJson.filter { k,v in 
            lightJson.keys.contains(k)
        }.map { k, darkValue in

            let lightValue = lightJson[k]!

            let darkColor = Color(components: Component(hex: colors[darkValue]!))
            let darkColors: Colors = Colors(color: darkColor, appearances: [Appearance()])

            let lightColor: Color = Color(components: Component(hex: colors[lightValue]!))
            let lightColors: Colors = Colors(color: lightColor, appearances: nil)

            return Token(colors: [lightColors, darkColors], info: Info(), filename: "\(k).colorset")
        }
        
        let jsonEncoder: JSONEncoder = JSONEncoder()
        var uiColors = ""
        var swiftColors: String = ""

        tokens.forEach { token in
            let data: Data = try! jsonEncoder.encode(token)
            try! FileManager().createDirectory(at: assets.appendingPathComponent(token.filename), withIntermediateDirectories: true)
            try! data.write(to: assets.appendingPathComponent("\(token.filename)/Contents.json"))

            let lightColor = token.colors[0].color.components
            let darkColor = token.colors[1].color.components
            
            let (lr, lg, lb, la) = (lightColor.redFloat, lightColor.greenFloat, lightColor.blueFloat, lightColor.alphaFloat)
            let (dr, dg, db, da) = (darkColor.redFloat, darkColor.greenFloat, darkColor.blueFloat, darkColor.alphaFloat)

            var varName = token.filename.replacingOccurrences(of: "_", with: "")
                .replacingOccurrences(of: ".colorset", with: "") 
                .replacingOccurrences(of: ".", with: "") 
            varName = varName.replacingOccurrences(of: String(varName.first!), with: String(varName.first!.lowercased()))

            swiftColors += """
            static let \(varName) = Color("\(token.filename.replacingOccurrences(of: ".colorset", with: ""))")

            """

            uiColors += """
                static var \(varName)Ui: UIColor {
                    return UIColor { (traits) -> UIColor in
                        return traits.userInterfaceStyle == .dark ?
                            UIColor(red: \(dr), green: \(dg), blue: \(db), alpha: \(da)) :
                            UIColor(red: \(lr), green: \(lg), blue: \(lb), alpha: \(la))
                    }
                }

            """
        } 

        swiftColors += """
            
            static let primaryColor = Color("Primary")
            static let primaryHomeColor = Color("PrimaryHome")
            static let secondaryColor = Color("Secondary")
            static let tertiaryColor = Color("tertiary")
            static let backdropColor = Color("backdrop")
            static let featureColor = Color("Feature")

            static let onImageSignalLow = Color.black.opacity(0.3)
            static let whiteOpacity10 = Color.white.opacity(0.4)
            static let whiteOpacity60 = Color.white.opacity(0.8)
        """
        
        let colorFileContent: String = """
            import SwiftUI

            
            /* ===================================
               = File is generated automatically =
               = see AddColors.swift             =
               ===================================*/


            extension Color {

                \(swiftColors)

                \(uiColors)
            }
        """

        do {
            try FileManager().removeItem(at: colorSwift) 
        } catch {
            print("couldn't delete colors file")
        }
        try! colorFileContent.data(using: .utf8)!.write(to: colorSwift)
    }
}
