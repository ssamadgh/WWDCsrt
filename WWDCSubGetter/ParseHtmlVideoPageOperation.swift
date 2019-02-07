//
//  ParseHtmlVideoPageOperation.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

enum SessionDataTypes: Hashable {
	
	
	case video(VideoQuality), pdf, sampleCode
}

class ParseHtmlVideoPageOperation: Operation {
	let cacheFile: URL
	
	let types: [SessionDataTypes]
	let sessionNumber: String
	
	
	init(for types: [SessionDataTypes], sessionNumber: String, cacheFile: URL) {
		self.cacheFile = cacheFile
		self.types = types
		self.sessionNumber = sessionNumber
		super.init()
		
		name = "ParseHtmlVideoPageOperation \(sessionNumber)"

	}
	
	override func execute() {
		executeOld()
	}
	
	func executeOld() {
		
		do {
			let data = try Data(contentsOf: self.cacheFile, options: Data.ReadingOptions.mappedIfSafe)
			
			let htmlText = String.init(data: data, encoding:
				.utf8)!
//			let quality: VideoQuality = self.types.contains(SessionDataTypes.video(.sd)) ? .sd : .hd

//			if !videoURLString.isEmpty {
			
				for type in types {
					
					switch type {
					case let .video(quality):
						let videoURLString = WWDCVideosController.getHDorSDdURLs(fromHTML: htmlText, format: quality)

						if quality == .hd {
							linksModel.hdVideosLinks.append(videoURLString)
						}
						else {
							linksModel.sdVideosLinks.append(videoURLString)
						}
						
					case .pdf:
						let pdfURLStrings = WWDCVideosController.getPDFResourceURL(fromHTML: htmlText)
						linksModel.pdfLinks.append(contentsOf: pdfURLStrings)
						
					case .sampleCode:
						let sampleCodesURLStrings = WWDCVideosController.getSampleCodeURL(fromHTML: htmlText)
						let sampleCodesURLStrings2 = WWDCVideosController.getSampleCodeURL2(fromHTML: htmlText)

						linksModel.sampleCodesLinks.append(contentsOf: sampleCodesURLStrings)
						linksModel.sampleCodesLinks.append(contentsOf: sampleCodesURLStrings2)

					}
				}
				
//			}
//			else {
//				try FileManager.default.removeItem(at: self.cacheFile)
//			}
			
			finish()

		}
		catch {
			print(error.localizedDescription)
			finish([error] as [NSError])
		}
		
	}
	
	func executeNew() {
		
	}

}
