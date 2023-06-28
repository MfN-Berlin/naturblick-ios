import Foundation

struct Image: Decodable {
    let url: String
}

struct CharacterValue: Decodable {
    let id: Int
    let image: Image?
    let colors: String?
    let dots: String?
}

enum ImportError: Error {
    case networkError
}

extension URLSession {
    static let validStatus = 200...299
    func httpData(from url: URL) async throws -> Data {
        guard let (data, response) = try await self.data(from: url, delegate: nil) as? (Data, HTTPURLResponse),
              URLSession.validStatus.contains(response.statusCode) else {
            throw ImportError.networkError
        }
        return data
    }
}

enum SvgGenerator {

    private static let svgStart = """
<?xml version="1.0" encoding="UTF-8" ?>
<svg
    width="74"
    height="74"
    viewBox="0 0 74 74">
"""

    private static let svgEnd = "</svg>"

    private static func stroke(_ color: String.SubSequence) -> String {
        let c = color.dropFirst(1)
        let c1 = Int(c.prefix(2), radix: 16)!
        let c2 = Int(c.dropFirst(2).prefix(2), radix: 16)!
        let c3 = Int(c.dropFirst(4).prefix(2), radix: 16)!
        if c1 > 0xe0 && c2 > 0xe0 && c3 > 0xe0 {
            return "stroke-width=\"1\" stroke=\"#0E3855\""
        } else {
            return ""
        }
    }

    private static func circles(colors: [String.SubSequence]) -> String {
        switch(colors.count) {
        case 3:
            return """
<path \(stroke(colors[0])) d="M37 44.1495C46.4302 44.1495 54.0748 36.5049 54.0748 27.0748C54.0748 17.6446 46.4302 10 37 10C27.5699 10 19.9253 17.6446 19.9253 27.0748C19.9253 36.5049 27.5699 44.1495 37 44.1495Z" fill="\(colors[0])"/>
<path \(stroke(colors[1])) d="M25.0072 63.6636C34.4 63.6636 42.0144 56.0493 42.0144 46.6564C42.0144 37.2636 34.4 29.6492 25.0072 29.6492C15.6144 29.6492 8 37.2636 8 46.6564C8 56.0493 15.6144 63.6636 25.0072 63.6636Z" fill="\(colors[1])"/>
<path \(stroke(colors[2])) d="M48.9928 63.6636C58.3856 63.6636 66 56.0493 66 46.6564C66 37.2636 58.3856 29.6492 48.9928 29.6492C39.6 29.6492 31.9856 37.2636 31.9856 46.6564C31.9856 56.0493 39.6 63.6636 48.9928 63.6636Z" fill="\(colors[2])"/>
"""
        case 2:
            return """
<path \(stroke(colors[0])) d="M26.0072 54.0144C35.4 54.0144 43.0144 46.4 43.0144 37.0072C43.0144 27.6144 35.4 20 26.0072 20C16.6144 20 9 27.6144 9 37.0072C9 46.4 16.6144 54.0144 26.0072 54.0144Z" fill="\(colors[0])"/>
<path \(stroke(colors[1])) d="M49.9928 54.0144C59.3856 54.0144 67 46.4 67 37.0072C67 27.6144 59.3856 20 49.9928 20C40.6 20 32.9856 27.6144 32.9856 37.0072C32.9856 46.4 40.6 54.0144 49.9928 54.0144Z" fill="\(colors[1])"/>
"""
        default:
            return """
<path \(stroke(colors[0])) d="M37.0072 54.0144C46.4 54.0144 54.0144 46.4 54.0144 37.0072C54.0144 27.6144 46.4 20 37.0072 20C27.6144 20 20 27.6144 20 37.0072C20 46.4 27.6144 54.0144 37.0072 54.0144Z" fill="\(colors[0])"/>
"""
        }
    }

    private static func dots(colors: [String.SubSequence], dotsOpt: String? = nil) -> String {
        if let dots = dotsOpt {
            switch (colors.count) {
            case 3:
                return """
<path d="M25.5 59C26.8807 59 28 57.8807 28 56.5C28 55.1193 26.8807 54 25.5 54C24.1193 54 23 55.1193 23 56.5C23 57.8807 24.1193 59 25.5 59Z" fill="\(dots)"/>
<path d="M15.5 51C16.8807 51 18 49.8807 18 48.5C18 47.1193 16.8807 46 15.5 46C14.1193 46 13 47.1193 13 48.5C13 49.8807 14.1193 51 15.5 51Z" fill="\(dots)"/>
<path d="M22.5 41C23.8807 41 25 39.8807 25 38.5C25 37.1193 23.8807 36 22.5 36C21.1193 36 20 37.1193 20 38.5C20 39.8807 21.1193 41 22.5 41Z" fill="\(dots)"/>
<path d="M48.5 41C49.8807 41 51 39.8807 51 38.5C51 37.1193 49.8807 36 48.5 36C47.1193 36 46 37.1193 46 38.5C46 39.8807 47.1193 41 48.5 41Z" fill="\(dots)"/>
<path d="M45.5 60C46.8807 60 48 58.8807 48 57.5C48 56.1193 46.8807 55 45.5 55C44.1193 55 43 56.1193 43 57.5C43 58.8807 44.1193 60 45.5 60Z" fill="\(dots)"/>
<path d="M41.5 51C42.8807 51 44 49.8807 44 48.5C44 47.1193 42.8807 46 41.5 46C40.1193 46 39 47.1193 39 48.5C39 49.8807 40.1193 51 41.5 51Z" fill="\(dots)"/>
<path d="M59.5 50C60.8807 50 62 48.8807 62 47.5C62 46.1193 60.8807 45 59.5 45C58.1193 45 57 46.1193 57 47.5C57 48.8807 58.1193 50 59.5 50Z" fill="\(dots)"/>
<path d="M28.5 28C29.8807 28 31 26.8807 31 25.5C31 24.1193 29.8807 23 28.5 23C27.1193 23 26 24.1193 26 25.5C26 26.8807 27.1193 28 28.5 28Z" fill="\(dots)"/>
<path d="M40.5 20C41.8807 20 43 18.8807 43 17.5C43 16.1193 41.8807 15 40.5 15C39.1193 15 38 16.1193 38 17.5C38 18.8807 39.1193 20 40.5 20Z" fill="\(dots)"/>
<path d="M39.5 28C40.8807 28 42 26.8807 42 25.5C42 24.1193 40.8807 23 39.5 23C38.1193 23 37 24.1193 37 25.5C37 26.8807 38.1193 28 39.5 28Z" fill="\(dots)"/>
"""
            case 2:
                return """
<path d="M27.5 47C28.8807 47 30 45.8807 30 44.5C30 43.1193 28.8807 42 27.5 42C26.1193 42 25 43.1193 25 44.5C25 45.8807 26.1193 47 27.5 47Z" fill="\(dots)"/>
<path d="M17.5 39C18.8807 39 20 37.8807 20 36.5C20 35.1193 18.8807 34 17.5 34C16.1193 34 15 35.1193 15 36.5C15 37.8807 16.1193 39 17.5 39Z" fill="\(dots)"/>
<path d="M24.5 29C25.8807 29 27 27.8807 27 26.5C27 25.1193 25.8807 24 24.5 24C23.1193 24 22 25.1193 22 26.5C22 27.8807 23.1193 29 24.5 29Z" fill="\(dots)"/>
<path d="M50.5 29C51.8807 29 53 27.8807 53 26.5C53 25.1193 51.8807 24 50.5 24C49.1193 24 48 25.1193 48 26.5C48 27.8807 49.1193 29 50.5 29Z" fill="\(dots)"/>
<path d="M47.5 48C48.8807 48 50 46.8807 50 45.5C50 44.1193 48.8807 43 47.5 43C46.1193 43 45 44.1193 45 45.5C45 46.8807 46.1193 48 47.5 48Z" fill="\(dots)"/>
<path d="M43.5 39C44.8807 39 46 37.8807 46 36.5C46 35.1193 44.8807 34 43.5 34C42.1193 34 41 35.1193 41 36.5C41 37.8807 42.1193 39 43.5 39Z" fill="\(dots)"/>
<path d="M61.5 38C62.8807 38 64 36.8807 64 35.5C64 34.1193 62.8807 33 61.5 33C60.1193 33 59 34.1193 59 35.5C59 36.8807 60.1193 38 61.5 38Z" fill="\(dots)"/>
"""
            default: return ""
            }
        } else {
            return ""
        }
    }

    static func svg(colors: [String.SubSequence], dotsOpt: String? = nil) -> String {
        return svgStart + circles(colors: colors) + dots(colors: colors, dotsOpt: dotsOpt) + svgEnd
    }
}

@main
enum GenerateCharacterAssets {
    static func main() async throws {
        let generatedAssets = URL(fileURLWithPath: FileManager().currentDirectoryPath).appendingPathComponent("naturblick/Generated.xcassets")

        if !FileManager.default.fileExists(atPath: generatedAssets.path) {
            try FileManager().createDirectory(at: generatedAssets, withIntermediateDirectories: true)
        }

        let decoder = JSONDecoder()
        let data = try await URLSession.shared.httpData(from: URL(string: "https://staging.naturblick.net/strapi/character-values?_limit=-1")!)
        let characters = try decoder.decode([CharacterValue].self, from: data)
        for character in characters {
            guard character.image != nil || (character.colors != nil && character.colors != "") else {
                continue
            }
            let assetDir = generatedAssets.appendingPathComponent("character_\(character.id).imageset")

            if !FileManager.default.fileExists(atPath: assetDir.path) {
                try FileManager().createDirectory(at: assetDir, withIntermediateDirectories: false)
            }

            if let image = character.image {
                let svgData = try await URLSession.shared.httpData(from: URL(string: "https://staging.naturblick.net/strapi" + image.url)!)
                try svgData.write(to: assetDir.appendingPathComponent("character_\(character.id).svg"))
            } else if let colors = character.colors {
                let image = SvgGenerator.svg(colors: colors.split(separator: ","), dotsOpt: character.dots)
                let svgData = Data(image.utf8)
                try svgData.write(to: assetDir.appendingPathComponent("character_\(character.id).svg"))
            }
            let assetContents = """
{
  "images" : [
    {
      "filename" : "character_\(character.id).svg",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "generate_character_assets",
    "version" : 1
  }
}
"""
            try Data(assetContents.utf8).write(to: assetDir.appendingPathComponent("Contents.json"))
        }
    }
}
