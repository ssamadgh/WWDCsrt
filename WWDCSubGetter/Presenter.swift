//
//  Presenter.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 1/22/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

class Presenter {
	
	let operationQueue = OperationQueue()
	
    func convertToSubtitle(from url: String, wwdc: WWDC, type: InputType, completion: @escaping ([Subtitle]) -> Void) {
        let convertToSubtitleOperation = ConvertToSubtitleOperation(from: url, wwdc: wwdc, type: type, completion: completion)
		self.operationQueue.addOperation(convertToSubtitleOperation)
	}
	
	func getSubtitles(completionHandler: @escaping () -> Void) {
		
		let operation = GetSubtitlesOperation(completionHandler: completionHandler)
		
		self.operationQueue.addOperation(operation)
	}
	
	func getLinks(for types: [SessionDataTypes], wwdcYear: WWDC, sessionNumber: String? = nil, copyToUserDestinationURL: Bool, completionHandler: @escaping () -> Void) {
		
		let getLinksOperation = GetLinksOperation(for: types, wwdcYear: wwdcYear, sessionNumber: sessionNumber, copyToUserDestinationURL: copyToUserDestinationURL, completionHandler: completionHandler)
		
		self.operationQueue.addOperation(getLinksOperation)

	}
	
	func getSessionsList(for wwdcYear: WWDC, copyToUserDestinationURL: Bool, completionHandler: @escaping () -> Void) {
		
		let getSessionsListOperation = GetSessionsListOperation(for: wwdcYear, copyToUserDestinationURL: copyToUserDestinationURL, completionHandler: completionHandler)
		
		self.operationQueue.addOperation(getSessionsListOperation)
	}
	
}
