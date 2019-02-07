//
//  Array+Extensions.swift

//
//  Created by Seyed Samad Gholamzadeh on 24/7/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


extension Array where Element: Hashable {
    
    /// A method which return unique values of array.
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()
		
		return filter {
			addedDict.updateValue(true, forKey: $0) == nil
		}
	}
	
	mutating func removeDuplicates() {
		self = self.removingDuplicates()
	}
}

