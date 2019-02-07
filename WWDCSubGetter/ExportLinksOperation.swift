//
//  ExportLinksOperation.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

/// A subclass of Operation which executes `exportSrtFile()` method for input subtitle.
final class ExportLinksOperation: Operation {
	
	let wwdcYear: WWDC
	let copyToUserDestinationURL: Bool
	
	/// - parameter subtitle: subtitle we want execute it's `exportSrtFile()` method.
	init(wwdcYear: WWDC, copyToUserDestinationURL: Bool) {
		self.wwdcYear = wwdcYear
		self.copyToUserDestinationURL = copyToUserDestinationURL
		
		super.init()
		name = "ExportLinksOperation"
	}
	
	
	override func execute() {
		
		let fileManager = FileManager.default
		
		//userDestinationURL
		let userDestinationURL = model.destinationURL!
		
		do {
			
			if copyToUserDestinationURL {
				if !fileManager.fileExists(atPath: userDestinationURL.path) {
					try fileManager.createDirectory(at: userDestinationURL, withIntermediateDirectories: true, attributes: nil)
				}
			}
			
			if !linksModel.titles.isEmpty, !copyToUserDestinationURL {
				let titlesURL = linksModel.titlesCacheURLFor(wwdcYear)
				let text = linksModel.titles.removingDuplicates().sorted().joined(separator: "\n")
				try text.write(to: titlesURL, atomically: false, encoding: String.Encoding.utf8)
			}
			
			if !linksModel.hdVideosLinks.isEmpty {
				let text = linksModel.hdVideosLinks.removingDuplicates().sorted().joined(separator: "\n")
				if copyToUserDestinationURL {
					let userHdVideoLinksURL = linksModel.userHdVideoLinksURLFor(wwdcYear)
					try text.write(to: userHdVideoLinksURL, atomically: false, encoding: String.Encoding.utf8)
				}
				else {
					let hdVideoLinksURL = linksModel.hdVideoCacheURLFor(wwdcYear)
					try text.write(to: hdVideoLinksURL, atomically: false, encoding: String.Encoding.utf8)
				}
			}
			
			if !linksModel.sdVideosLinks.isEmpty {
				let text = linksModel.sdVideosLinks.removingDuplicates().sorted().joined(separator: "\n")
				if copyToUserDestinationURL {
					let userSdVideoLinksURL = linksModel.userSdVideoLinksURLFor(wwdcYear)
					try text.write(to: userSdVideoLinksURL, atomically: false, encoding: String.Encoding.utf8)
				}
				else {
					let sdVideoLinksURL = linksModel.sdVideoCacheURLFor(wwdcYear)
					try text.write(to: sdVideoLinksURL, atomically: false, encoding: String.Encoding.utf8)
				}
			}
			
			if !linksModel.pdfLinks.isEmpty {
				let text = linksModel.pdfLinks.removingDuplicates().sorted().joined(separator: "\n")
				if copyToUserDestinationURL {
					let userPdfLinksURL = linksModel.userPdfLinksURLFor(wwdcYear)
					try text.write(to: userPdfLinksURL, atomically: false, encoding: String.Encoding.utf8)
				}
				else {
					let pdfLinksURL = linksModel.pdfLinksCacheURLFor(wwdcYear)
					try text.write(to: pdfLinksURL, atomically: false, encoding: String.Encoding.utf8)
				}
			}
			
			if !linksModel.sampleCodesLinks.isEmpty {
				let text = linksModel.sampleCodesLinks.removingDuplicates().sorted().joined(separator: "\n")
				if copyToUserDestinationURL {
					let userSampleCodesLinksURL = linksModel.userSampleCodesLinksURLFor(wwdcYear)
					try text.write(to: userSampleCodesLinksURL, atomically: false, encoding: String.Encoding.utf8)
				}
				else {
					let sampleCodesLinksURL = linksModel.sampleCodesLinksCacheURLFor(wwdcYear)
					try text.write(to: sampleCodesLinksURL, atomically: false, encoding: String.Encoding.utf8)
					
				}
				
			}
			
		}
		catch {/* error handling here */
			print(error.localizedDescription)
		}
		
		linksModel.clear()
		finish()
	}
}
