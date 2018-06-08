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
		
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let destinationURL = cachesFolder.appendingPathComponent("com.samad.WWDC.srt/\(wwdcYear.stringValue)/", isDirectory: true)
		
		let fileManager = FileManager.default
		
		//userDestinationURL
		let userDestinationURL = model.destinationURL!
		
		do {
			
			if copyToUserDestinationURL {
				if !fileManager.fileExists(atPath: userDestinationURL.path) {
					try fileManager.createDirectory(at: userDestinationURL, withIntermediateDirectories: true, attributes: nil)
				}
			}
			
			if !linksModel.titles.isEmpty {
				let titlesURL = linksModel.titlesCacheURLFor(wwdcYear)
				let text = linksModel.titles.unique().sorted().joined(separator: "\n")
				try text.write(to: titlesURL, atomically: false, encoding: String.Encoding.utf8)
			}

			
			if !linksModel.hdVideosLinks.isEmpty {
				let hdVideoLinksURL = linksModel.hdVideoCacheURLFor(wwdcYear)
				let text = linksModel.hdVideosLinks.unique().sorted().joined(separator: "\n")
				try text.write(to: hdVideoLinksURL, atomically: false, encoding: String.Encoding.utf8)
				
				if copyToUserDestinationURL {
					
					let userHdVideoLinksURL = linksModel.userHdVideoLinksURLFor(wwdcYear)
					if fileManager.fileExists(atPath: userHdVideoLinksURL.path) {
						try fileManager.removeItem(at: userHdVideoLinksURL)
					}
					try fileManager.copyItem(at: hdVideoLinksURL, to: userHdVideoLinksURL)
				}
			}
			
			if !linksModel.sdVideosLinks.isEmpty {
				let sdVideoLinksURL = linksModel.sdVideoCacheURLFor(wwdcYear)
				let text = linksModel.sdVideosLinks.unique().sorted().joined(separator: "\n")
				try text.write(to: sdVideoLinksURL, atomically: false, encoding: String.Encoding.utf8)
				
				if copyToUserDestinationURL {
					let userSdVideoLinksURL = linksModel.userSdVideoLinksURLFor(wwdcYear)
					if fileManager.fileExists(atPath: userSdVideoLinksURL.path) {
						try fileManager.removeItem(at: userSdVideoLinksURL)
					}
					try fileManager.copyItem(at: sdVideoLinksURL, to: userSdVideoLinksURL)
				}

			}

			if !linksModel.pdfLinks.isEmpty {
				let pdfLinksURL = linksModel.pdfLinksCacheURLFor(wwdcYear)
				let text = linksModel.pdfLinks.unique().sorted().joined(separator: "\n")
				try text.write(to: pdfLinksURL, atomically: false, encoding: String.Encoding.utf8)
				
				if copyToUserDestinationURL {
					let userPdfLinksURL = linksModel.userPdfLinksURLFor(wwdcYear)
					if fileManager.fileExists(atPath: userPdfLinksURL.path) {
						try fileManager.removeItem(at: userPdfLinksURL)
					}
					try fileManager.copyItem(at: pdfLinksURL, to: userPdfLinksURL)
				}
			}

			if !linksModel.sampleCodesLinks.isEmpty {
				let sampleCodesLinksURL = linksModel.sampleCodesLinksCacheURLFor(wwdcYear)
				let text = linksModel.sampleCodesLinks.unique().sorted().joined(separator: "\n")
				try text.write(to: sampleCodesLinksURL, atomically: false, encoding: String.Encoding.utf8)
				
				if copyToUserDestinationURL {
					let userSampleCodesLinksURL = linksModel.userSampleCodesLinksURLFor(wwdcYear)
					if fileManager.fileExists(atPath: userSampleCodesLinksURL.path) {
						try fileManager.removeItem(at: userSampleCodesLinksURL)
					}
					try fileManager.copyItem(at: sampleCodesLinksURL, to: userSampleCodesLinksURL)
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
