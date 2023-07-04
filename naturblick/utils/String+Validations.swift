//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

extension String {
    
    func containsDigits() -> Bool {
        let digitTest = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
        return digitTest.evaluate(with: self)
    }
    
    func containsLowercase() -> Bool {
        let digitTest = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
        return digitTest.evaluate(with: self)
    }
    
    func containsUppercase() -> Bool {
        let digitTest = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        return digitTest.evaluate(with: self)
    }
    
    func isEmail() -> Bool {
         let emailTest = NSPredicate(format: "SELF MATCHES %@", "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$")
         return emailTest.evaluate(with: self)
    }
    
}
