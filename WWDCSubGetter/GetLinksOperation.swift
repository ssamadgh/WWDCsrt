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
	
	var fetchHtmlVideoPagesOperation: FetchHtmlVideoPagesOperation
	var exportLinksOperation: ExportLinksOperation!
	
	init(for types: [SessionDataTypes], wwdcYear: WWDC, sessionNumber: String? = nil, copyToUserDestinationURL: Bool, completionHandler: @escaping () -> Void) {
		self.wwdcYear = wwdcYear
		
		//com.samad.WWDC.srt
		
		self.fetchHtmlVideoPagesOperation = FetchHtmlVideoPagesOperation(for: types, wwdcYear: wwdcYear, sessionNumber: sessionNumber)
		
		self.exportLinksOperation = ExportLinksOperation(wwdcYear: wwdcYear, copyToUserDestinationURL: copyToUserDestinationURL)
		
		let finishOperation = Foundation.BlockOperation(block: completionHandler)
		
		self.exportLinksOperation.addDependency(self.fetchHtmlVideoPagesOperation)
		finishOperation.addDependency(self.exportLinksOperation!)
		
		
		let operations = [self.fetchHtmlVideoPagesOperation, self.exportLinksOperation, finishOperation].filter { $0 != nil } as! [Foundation.Operation]
		
		
		super.init(operations: operations)
		
		self.name = "GetLinksOperation"
	}
	
}
