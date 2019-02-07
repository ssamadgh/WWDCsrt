//
//  PrseSessionsListOperation.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


class ParseSessionsListOperation: Operation {
	
	//MARK: Properties
	
	let sessionListURL: URL
	let wwdcYear: WWDC
	
	//MARK: Initializer
	
	init(for wwdcYear: WWDC, cacheFile: URL) {
		
		self.sessionListURL = cacheFile
		self.wwdcYear = wwdcYear
		
		super.init()
		self.name = "ParseSessionsListOperation"
	}
	
	override func execute() {
		
		do {
			
			var sessionsListArray: [String] = []
			
			let data = try Data(contentsOf: self.sessionListURL, options: Data.ReadingOptions.mappedIfSafe)
			
			let htmlSessionListString = String.init(data: data, encoding:
				String.Encoding.utf8)!
			
			sessionsListArray = WWDCVideosController.getSessionsList(fromHTML: htmlSessionListString, wwdcYear: wwdcYear.stringValue)
			
			//get unique values
			sessionsListArray = Array(Set(sessionsListArray)).sorted()
			
			linksModel.titles = sessionsListArray
			
			if !linksModel.titles.isEmpty {
				let titlesURL = linksModel.titlesCacheURLFor(wwdcYear)
				let text = linksModel.titles.removingDuplicates().sorted().joined(separator: "\n")
				try text.write(to: titlesURL, atomically: false, encoding: String.Encoding.utf8)
			}

		} catch {
			
			print(error)
		}
		
		linksModel.clear()
		finish()
	}
	
}
