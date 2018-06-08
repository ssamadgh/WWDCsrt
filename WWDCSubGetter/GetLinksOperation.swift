//
//  GetLinksOperation.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Cocoa

final class GetLinksOperation: GroupOperation {
	
	var wwdcYear: WWDC
	var getSessionsListOperation: GetHtmlSessionsListOperation?
	var parseSessionsListOperation: ParseSessionsListOperation
	var exportLinksOperation: ExportLinksOperation!
	
	init(for types: [SessionDataTypes], wwdcYear: WWDC, sessionNumber: String? = nil, copyToUserDestinationURL: Bool, completionHandler: @escaping () -> Void) {
		self.wwdcYear = wwdcYear
		
		//com.samad.WWDC.srt
		
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let downloadLinksCacheFolder = cachesFolder.appendingPathComponent("com.samad.WWDC.srt/\(wwdcYear.stringValue)/", isDirectory: true)
		let fileManager = FileManager.default
		
		if !fileManager.fileExists(atPath: downloadLinksCacheFolder.path) {
			
			try! FileManager.default.createDirectory(atPath: downloadLinksCacheFolder.path, withIntermediateDirectories: true, attributes: nil)
		}
		
		let sessionListURL = downloadLinksCacheFolder.appendingPathComponent("sessionList.html")
		
		if sessionNumber == nil {
			self.getSessionsListOperation = GetHtmlSessionsListOperation(wwdcYear: wwdcYear, cacheFile: sessionListURL)
		}
		
		if sessionNumber == nil {
			self.parseSessionsListOperation = ParseSessionsListOperation(for:types, wwdcYear: wwdcYear, cacheFile: sessionListURL)
		}
		else {
			self.parseSessionsListOperation = ParseSessionsListOperation(for:types, wwdcYear: wwdcYear, sessionNumber: sessionNumber, cacheFile: sessionListURL)
		}

		self.exportLinksOperation = ExportLinksOperation(wwdcYear: wwdcYear, copyToUserDestinationURL: copyToUserDestinationURL)
		
		let finishOperation = Foundation.BlockOperation(block: completionHandler)

		if self.getSessionsListOperation != nil {
			self.parseSessionsListOperation.addDependency(self.getSessionsListOperation!)
		}
		
		self.exportLinksOperation.addDependency(self.parseSessionsListOperation)
		finishOperation.addDependency(self.exportLinksOperation!)

		
		let operations = [self.getSessionsListOperation, self.parseSessionsListOperation, self.exportLinksOperation, finishOperation].filter { $0 != nil } as! [Foundation.Operation]
		
		
		super.init(operations: operations)
		
		self.name = "GetLinksOperation"
	}

}
