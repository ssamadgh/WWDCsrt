//
//  PrseSessionsListOperation.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


class ParseSessionsListOperation: GroupOperation {
	
	//MARK: Properties
	
	let sessionListURL: URL
	let wwdcYear: WWDC
	let types: [SessionDataTypes]
	let sessionNumber: String?
	//MARK: Initializer
	
	init(for types: [SessionDataTypes], wwdcYear: WWDC, sessionNumber: String? = nil, cacheFile: URL) {
		self.sessionListURL = cacheFile
		self.wwdcYear = wwdcYear
		self.types = types
		self.sessionNumber = sessionNumber
		
		super.init(operations: [])
		self.name = "ParseSessionsListOperation"
	}
	
	override func execute() {
		
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let downloadLinksCacheFolder = cachesFolder.appendingPathComponent("com.samad.WWDC.srt/\(wwdcYear.stringValue)/", isDirectory: true)
				
		var operations: [Foundation.Operation] = []
		
		do {
			
			var sessionsListArray: [String] = []
			
			if self.sessionNumber == nil {
				let data = try Data(contentsOf: self.sessionListURL)
				
				let htmlSessionListString = String.init(data: data, encoding:
					.ascii)!
				
				sessionsListArray = WWDCVideosController.getSessionsList(fromHTML: htmlSessionListString, wwdcYear: wwdcYear.stringValue)
				//get unique values
				sessionsListArray=Array(Set(sessionsListArray))
			}
			else {
				sessionsListArray = [self.sessionNumber!]
			}
			
			for sessionNumber in sessionsListArray {
				
				let htmlURL = downloadLinksCacheFolder.appendingPathComponent("\(sessionNumber).html")
				
				let getHtmlOperation = GetHtmlVideoPageOperation(wwdcYear: wwdcYear, sessionNumber: sessionNumber, cacheFile: htmlURL)
				operations.append(getHtmlOperation)

				let parseHtmlOperation = ParseHtmlVideoPageOperation(for: types, sessionNumber: sessionNumber, cacheFile: htmlURL)
				
				parseHtmlOperation.addDependency(getHtmlOperation)
				operations.append(parseHtmlOperation)
			}
			
		} catch {
			
			print(error)
		}

		addOperations(operations)
		
		super.execute()

	}
	
}
