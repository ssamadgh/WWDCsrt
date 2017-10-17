//
//  Array+Extensions.swift

//
//  Created by Seyed Samad Gholamzadeh on 24/7/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


extension Array where Element: Hashable {
    
    /// A method which return unique values of array.
    func unique() -> [Element] {
        
        var buffer = [Element]()
        
        var added = Set<Element>()
        
        for elem in self {
            
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

