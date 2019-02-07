//
//  WWDC_srtTests.swift
//  WWDC.srtTests
//
//  Created by Seyed Samad Gholamzadeh on 2/7/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import WWDC_srt

class WWDC_srtTests: XCTestCase {

	let presenter = Presenter()
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVideoParsing() {
		let fileName = "708"
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: fileName, withExtension: "html")!
		let data = try! Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
		
		let htmlText = String.init(data: data, encoding:
			.utf8)!
		
		self.measure {
			let videoURLString = WWDCVideosController.getHDorSDdURLs(fromHTML: htmlText, format: .sd)
			print(videoURLString)
//	
//			let pdfURLStrings = WWDCVideosController.getPDFResourceURL(fromHTML: htmlText)
//			let sampleCodesURLStrings = WWDCVideosController.getSampleCodeURL(fromHTML: htmlText)
//			let sampleCodesURLStrings2 = WWDCVideosController.getSampleCodeURL2(fromHTML: htmlText)
		}
		
	}

    func testPdfParsing() {
		let fileName = "708"
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: fileName, withExtension: "html")!
		let data = try! Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
		
		let htmlText = String.init(data: data, encoding:
			.utf8)!
		
		self.measure {
			let pdfURLStrings = WWDCVideosController.getPDFResourceURL(fromHTML: htmlText)
			print(pdfURLStrings)

			//			let sampleCodesURLStrings = WWDCVideosController.getSampleCodeURL(fromHTML: htmlText)
			//			let sampleCodesURLStrings2 = WWDCVideosController.getSampleCodeURL2(fromHTML: htmlText)
		}
    }
	
	func testZipParsing() {
		
		let fileName = "505"
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: fileName, withExtension: "html")!
		let data = try! Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
		
		let htmlText = String.init(data: data, encoding:
			.utf8)!
		
		self.measure {
			let sampleCodesURLStrings = WWDCVideosController.getSampleCodeURL(fromHTML: htmlText)
			print("sampleCodesURLStrings: ", sampleCodesURLStrings.count)

			let sampleCodesURLStrings2 = WWDCVideosController.getSampleCodeURL2(fromHTML: htmlText)
			print("sampleCodesURLStrings2: ", sampleCodesURLStrings2.count)
		}
		
	}


}
