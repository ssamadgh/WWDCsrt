//
//  LinksModel.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

class SafeLinksModel {
    
    var queue = DispatchQueue(label: "LinkModel_Thread_Safe_Queue")
    
    private var _linksModel = LinksModel()

    
    var linksModel: LinksModel {
        get {
            queue.sync {
                return self._linksModel
            }
        }
        
        set {
            queue.async {
                self._linksModel = newValue
            }
        }
    }
    
}

fileprivate var safeLinksModel = SafeLinksModel()
var linksModel: LinksModel {
    get {
        return safeLinksModel.linksModel
    }
    
    set {
        safeLinksModel.linksModel = newValue
    }
}

struct LinksModel {
	var titles: [String] = []
	var hdVideosLinks: [String] = []
	var sdVideosLinks: [String] = []
	var pdfLinks: [String] = []
	var sampleCodesLinks: [String] = []
	let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

	
	mutating func clear() {
		self.hdVideosLinks.removeAll()
		self.sdVideosLinks.removeAll()
		self.pdfLinks.removeAll()
		self.sampleCodesLinks.removeAll()
		self.titles.removeAll()
	}
	
    var cacheDestinationURL: URL {
        let destinationURL = cachesFolder.appendingPathComponent("com.samad.WWDC.srt", isDirectory: true)
        return destinationURL
    }
    
	func cacheDestinationURFor(_ wwdcYear: WWDC) -> URL {
		let destinationURL = cachesFolder.appendingPathComponent("com.samad.WWDC.srt/\(wwdcYear.stringValue)/", isDirectory: true)
		return destinationURL
	}

	
	func titlesCacheURLFor(_ wwdcYear: WWDC) -> URL {
		let destinationURL = cacheDestinationURFor(wwdcYear)
		let titlesURL = destinationURL.appendingPathComponent("\(wwdcYear.stringValue)_sessions_titles.txt")
		
		return titlesURL
	}
	
	
	func hdVideoLinksFileNameFor(_ wwdcYear: WWDC) -> String {
		return "\(wwdcYear.stringValue)_hd_video_links.txt"
	}
	
	func hdVideoCacheURLFor(_ wwdcYear: WWDC) -> URL {
		let destinationURL = cacheDestinationURFor(wwdcYear)
		let titlesURL = destinationURL.appendingPathComponent(hdVideoLinksFileNameFor(wwdcYear))
		
		return titlesURL
	}
	
	func userHdVideoLinksURLFor(_ wwdcYear: WWDC) -> URL {
		let userDestinationURL = model.destinationURL!
		let userHdVideoLinksURL = userDestinationURL.appendingPathComponent(hdVideoLinksFileNameFor(wwdcYear))
		return userHdVideoLinksURL
	}
	
	func sdVideoLinksFileNameFor(_ wwdcYear: WWDC) -> String {
		return "\(wwdcYear.stringValue)_sd_video_links.txt"
	}

	func sdVideoCacheURLFor(_ wwdcYear: WWDC) -> URL {
		let destinationURL = cacheDestinationURFor(wwdcYear)
		let titlesURL = destinationURL.appendingPathComponent(sdVideoLinksFileNameFor(wwdcYear))
		
		return titlesURL
	}
	
	func userSdVideoLinksURLFor(_ wwdcYear: WWDC) -> URL {
		let userDestinationURL = model.destinationURL!
		let userSdVideoLinksURL = userDestinationURL.appendingPathComponent(sdVideoLinksFileNameFor(wwdcYear))
		return userSdVideoLinksURL
	}

	func pdfLinksFileNameFor(_ wwdcYear: WWDC) -> String {
		return "\(wwdcYear.stringValue)_pdf_links.txt"
	}
	
	func pdfLinksCacheURLFor(_ wwdcYear: WWDC) -> URL {
		let destinationURL = cacheDestinationURFor(wwdcYear)
		let titlesURL = destinationURL.appendingPathComponent(pdfLinksFileNameFor(wwdcYear))
		
		return titlesURL
	}
	
	func userPdfLinksURLFor(_ wwdcYear: WWDC) -> URL {
		let userDestinationURL = model.destinationURL!
		let userPdfLinksURL = userDestinationURL.appendingPathComponent(pdfLinksFileNameFor(wwdcYear))
		return userPdfLinksURL
	}

	func sampleCodesLinksFileNameFor(_ wwdcYear: WWDC) -> String {
		return "\(wwdcYear.stringValue)_sample_codes_links.txt"
	}

	func sampleCodesLinksCacheURLFor(_ wwdcYear: WWDC) -> URL {
		let destinationURL = cacheDestinationURFor(wwdcYear)
		let titlesURL = destinationURL.appendingPathComponent(sampleCodesLinksFileNameFor(wwdcYear))
		
		return titlesURL
	}

	func userSampleCodesLinksURLFor(_ wwdcYear: WWDC) -> URL {
		let userDestinationURL = model.destinationURL!
		let userSampleCodesLinksURL = userDestinationURL.appendingPathComponent(sampleCodesLinksFileNameFor(wwdcYear))
		return userSampleCodesLinksURL
	}


	
}
