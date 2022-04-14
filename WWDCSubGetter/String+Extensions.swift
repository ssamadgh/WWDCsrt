//
//  String+Extensions.swift

//
//  Created by Seyed Samad Gholamzadeh on 9/9/1395 AP.
//  Copyright © 1395 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import CoreGraphics
import CoreText
import Foundation

typealias RegexPattern = String

extension CGColor {
    open static var yellow: CGColor {
        return CGColor(red: 1, green: 1, blue: 0, alpha: 1)
    }
}

extension String {
    /*
    Here's a way to change it on the fly with Swift, add an extension function to String:
    Assuming you have the regular Localizable.strings set up with lang_id.lproj ( e.g. en.lproj, de.lproj etc. ) you can use this anywhere you need:
    var val = "MY_LOCALIZED_STRING".localized("de")
 */
    func localized(lang:String) ->String {
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    func replace(_ letters: String, with newLetters: String) -> String {
        return self.replacingOccurrences(of: letters, with: newLetters, options: .literal, range: nil)
    }
    
    //MARK: - Regular Expression methods
    
    @available(OSX 10.12, *)
    func highlight(matches pattern: RegexPattern) -> NSAttributedString? {
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, self.characters.count)
            let matches = regex.matches(in: self, options: [], range: range)
            let attributedText = NSMutableAttributedString(string: self)
            
            for match in matches {
                #if TARGET_OS_IPHONE
                    // iOS code
                    attributedText.addAttribute(NSBackgroundColorAttributeName, value: CGColor.yellow, range: match.range)
                #else
                    // OSX code
                    //                    attributedText.ad
                    attributedText.addAttribute(NSAttributedStringKey(rawValue: kCTBackgroundColorAttributeName as String), value: CGColor.yellow, range: match.range)
                    
                #endif
                
            }
            return attributedText.copy() as? NSAttributedString
            
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func list( matches pattern: RegexPattern) -> [String]? {
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, self.characters.count)
            let matches = regex.matches(in: self, options: [], range: range)
            return matches.map {
                let range = $0.range
                return (self as NSString).substring(with: range)
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func captureGroups(with pattern: RegexPattern) -> [String]? {
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, self.count)
            let matches = regex.matches(in: self, options: [], range: range)
            
            var groupMatches = [String]()
            for match in matches {
                let rangeCount = match.numberOfRanges
                
                for group in 0..<rangeCount {
                    groupMatches.append((self as NSString).substring(with: match.range(at: group)))
                }
            }
            return groupMatches
            
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func contains(_ pattern: RegexPattern) -> Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, self.characters.count)
            return regex.firstMatch(in: self, options: [], range: range) != nil
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
    }
    
    func replace(matches pattern: RegexPattern, with replacementString: String) -> String? {
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, self.characters.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacementString)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }



}
