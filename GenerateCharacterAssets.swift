import Foundation

struct Image: Decodable {
    let url: String
}

struct CharacterValue: Decodable {
    let id: Int
    let image: Image?
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
        let characterIdAndImageUrls: [(Int, String)] = characters.compactMap { character in
            if let image = character.image {
                return (character.id, image.url)
            } else {
                return nil
            }
        }
        for (id, url) in characterIdAndImageUrls {
            let svgData = try await URLSession.shared.httpData(from: URL(string: "https://staging.naturblick.net/strapi" + url)!)
            let assetDir = generatedAssets.appendingPathComponent("character_\(id).imageset")

            if !FileManager.default.fileExists(atPath: assetDir.path) {
                try FileManager().createDirectory(at: assetDir, withIntermediateDirectories: false)
            }
            try svgData.write(to: assetDir.appendingPathComponent("character_\(id).svg"))
            let assetContents = """
{
  "images" : [
    {
      "filename" : "character_\(id).svg",
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
