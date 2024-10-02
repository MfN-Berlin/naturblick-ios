import Foundation

struct Component : Encodable {
    let alpha: String
    let blue: String
    let green: String
    let red: String

    init(hex: String) {
        let rstart = hex.index(hex.startIndex, offsetBy: 1)
        let rend = hex.index(hex.startIndex, offsetBy: 3)
        let rrange = rstart..<rend
        red = "0x\(hex[rrange].uppercased())"

        let gstart = hex.index(hex.startIndex, offsetBy: 3)
        let gend = hex.index(hex.startIndex, offsetBy: 5)
        let grange = gstart..<gend
        green = "0x\(hex[grange].uppercased())"

        let bstart = hex.index(hex.startIndex, offsetBy: 5)
        let bend = hex.index(hex.startIndex, offsetBy: 7)
        let brange = bstart..<bend
        blue = "0x\(hex[brange].uppercased())"

        if (hex.count == 9) {
            let astart = hex.index(hex.startIndex, offsetBy: 7)
            let aend = hex.index(hex.startIndex, offsetBy: 9)
            let arange = astart..<aend

            let decimal = UInt8(hex[arange], radix: 16) 
            let opacity: Double = Double(decimal!) / 255
            alpha = String(format: "%.3f", opacity) 
            
        } else {
            alpha = "1.000"
        }
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
        jsonEncoder.outputFormatting = .sortedKeys

        tokens.forEach { token in
             let data: Data = try! jsonEncoder.encode(token)
             try! FileManager().createDirectory(at: assets.appendingPathComponent(token.filename), withIntermediateDirectories: true)
             try! data.write(to: assets.appendingPathComponent("\(token.filename)/Contents.json"))
        } 
    }
}
