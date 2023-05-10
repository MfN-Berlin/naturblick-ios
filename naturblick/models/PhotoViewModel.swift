//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import SQLite

class PhotoViewModel : ObservableObject {
    
    @Published private(set) var img: UIImage? = nil
    private var results: [SpeciesResult]? = nil
    @Published private(set) var species: [Species]? = nil
    
    var crop: UIImage? {
        get {
            guard let uiImg = img else { return nil }
            guard let cgImg = uiImg.cgImage else { return nil }
            
            let x = uiImg.size.width / 2 - 448 / 2
            let y = uiImg.size.height / 2 - 448 / 2
            
            guard let crop = cgImg.cropping(to:  CGRect(x: x, y: y, width: 448, height: 448)) else { return nil }
            
            return UIImage(cgImage: crop)
        }
    }
    
    func setSpeciesResult(results: [SpeciesResult]) {
        self.results = results
        guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
            preconditionFailure("Failed to find database file")
        }
        
        let ids = results.map { $0.id }
        
        do {
            let speciesDb = try Connection(path, readonly: true)
            let query = Species.Definition.table
                .filter(ids.contains(Species.Definition.id))
            
            do {
                species = try speciesDb.prepareRowIterator(query).map { row in
                    Species(id: row[Species.Definition.id],
                            group: row[Species.Definition.group],
                            sciname: row[Species.Definition.sciname],
                            gername: row[Species.Definition.gername],
                            engname: row[Species.Definition.engname],
                            wikipedia: row[Species.Definition.wikipedia],
                            maleUrl: row[Species.Definition.maleUrl],
                            femaleUrl: row[Species.Definition.femaleUrl],
                            gersynonym: row[Species.Definition.gersynonym],
                            engsynonym: row[Species.Definition.engsynonym],
                            redListGermany: row[Species.Definition.redListGermany],
                            iucnCategory: row[Species.Definition.iucnCategory])
                }
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
    
    
    
    func setImage(img: UIImage) {
        self.img = img
        savePhoto(img: img)
    }
    
    func savePhoto(img: UIImage) {
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}
