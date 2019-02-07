//
//  PrseSessionsListOperation.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


class FetchHtmlVideoPagesOperation: GroupOperation {
	
	//MARK: Properties
	
//	let sessionListURL: URL
	let wwdcYear: WWDC
	let types: [SessionDataTypes]
	let sessionNumber: String?
	//MARK: Initializer
	
	init(for types: [SessionDataTypes], wwdcYear: WWDC, sessionNumber: String?) {

		self.wwdcYear = wwdcYear
		self.types = types
		self.sessionNumber = sessionNumber
		
		super.init(operations: [])
		self.name = "ParseSessionsListOperation"
		self.limitMaxConcurrentOperations(to: 3)
	}
	
	override func execute() {
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let downloadLinksCacheFolder = cachesFolder.appendingPathComponent("com.samad.WWDC.srt/\(wwdcYear.stringValue)/", isDirectory: true)
		
		var operations: [Foundation.Operation] = []
		
		do {
			
			var sessionNumbers: [String] = []
			
			if self.sessionNumber == nil {
				
				let titleURL = linksModel.titlesCacheURLFor(wwdcYear)
				
				if FileManager.default.fileExists(atPath: titleURL.path) {
					
					let data = try String(contentsOfFile:titleURL.path, encoding: String.Encoding.utf8)
					let sessionsListArray = data.components(separatedBy: "\n")
					sessionNumbers = sessionsListArray.compactMap { String($0.split(separator: " ").first!) }
					
				}
				
			}
			else {
				sessionNumbers = [self.sessionNumber!]
			}
			
			for sessionNumber in sessionNumbers {
				
				let htmlURL = downloadLinksCacheFolder.appendingPathComponent("\(sessionNumber).html")
				
				let parseHtmlOperation = ParseHtmlVideoPageOperation(for: types, sessionNumber: sessionNumber, cacheFile: htmlURL)
				
				if self.wwdcYear == lastWWDC {
					let getHtmlOperation = DownloadHtmlVideoPageOperation(wwdcYear: wwdcYear, sessionNumber: sessionNumber, cacheFile: htmlURL)
					operations.append(getHtmlOperation)
					
					
					parseHtmlOperation.addDependency(getHtmlOperation)
				}
				else if !FileManager.default.fileExists(atPath: htmlURL.path) {
					
					let getHtmlOperation = DownloadHtmlVideoPageOperation(wwdcYear: wwdcYear, sessionNumber: sessionNumber, cacheFile: htmlURL)
					operations.append(getHtmlOperation)
					
					
					parseHtmlOperation.addDependency(getHtmlOperation)
				}
				
				operations.append(parseHtmlOperation)
			}
			
		} catch {
			
			print(error)
		}
		
		addOperations(operations)
		
		super.execute()
		
	}
	
}
