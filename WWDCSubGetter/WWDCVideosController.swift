//
//  WWDCVideosController.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 6/5/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import SystemConfiguration


enum VideoQuality: String {
	case hd = "hd"
	case sd = "sd"
}


class WWDCVideosController {
	
	class func getSessionsList(fromHTML: String, wwdcYear: String) -> [String] {
		
		let nsFromHTML = fromHTML as NSString
//		let pat = "video-title\\\\\"\\>(.*?)\\<\\/h\\d\\>"
		let pat = "href=\"\\/videos\\/play\\/[^ ]*?\\/([0-9]*)\\/\".*?video-title\"\\>(.*?)\\<\\/h\\d\\>"

		let regex = try! NSRegularExpression(pattern: pat, options: NSRegularExpression.Options.dotMatchesLineSeparators)
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		
		var sessionsListArray = [String]()
		
		
		matches.forEach { (match) in
			let numRange = match.range(at: 1)
			let titleRange = match.range(at: 2)
			let sessionNumber = nsFromHTML.substring(with: numRange) + " _ " + nsFromHTML.substring(with: titleRange)
			
			sessionsListArray.append(sessionNumber)
			
		}
		
		return sessionsListArray
	}
	
	class func getHDorSDdURLs(fromHTML: String, format: VideoQuality) -> (String) {
		
		let formatValue = format == .hd ? "[hH][dD]" : "[sS][dD]"
		
//		let pat = "\\b.*?(http(?:s)?://.*?" + formatValue + ".*?\\.m[op4][v4a])\\b"
		let pat = "(http(?:s)?[^ ]*?" + formatValue + "[^ ]*?)\\?dl"
//		let pat = "(http(?:s)?[^ ]*?" + formatValue + "[^ ]*?\\.(?:mp4|m4a|mov))"
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		
		var videoURL = ""
		if !matches.isEmpty {
			let range = matches[0].range(at: 1)
			videoURL = (fromHTML as NSString).substring(with: range)
		}
		
		return videoURL
	}
	
	class func getPDFResourceURL(fromHTML: String) -> [String] {
//		let pat = "\\b.*(http(?:s)?://.*\\.pdf)\\b"
		let pat = "(http(?:s)?[^ ]*?\\.pdf)\\?dl"

		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
//		var pdfResourceURL = ""
//		if !matches.isEmpty {
//			let range = matches[0].range(at: 1)
//			let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
//				fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
//			pdfResourceURL = String(fromHTML[r])
//		}
//
//		return pdfResourceURL
		
		var pdfResourceURLPaths : [String] = []
		for match in matches {
			let range = match.range(at: 1)
			let path = (fromHTML as NSString).substring(with: range)
			pdfResourceURLPaths.append(path)
		}
		
		return pdfResourceURLPaths
	}
	
	class func getSampleCodeURL(fromHTML: String) -> [String] {
		let pat = "(href=\"[^ ]*?/content/samplecode/.*?=\")"
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		var sampleURLPaths : [String] = []
		for match in matches {
			let range = match.range(at: 1)
			var path = (fromHTML as NSString).substring(with: range)
			
			// Tack on the hostname if it's not already there (some URLs are listed as
			// relative URL while some are fully-qualified).
			let prefixReplacementString: String
			if !path.contains("href=\"http") {
				prefixReplacementString = "http(?:s)?://developer.apple.com"
			} else {
				prefixReplacementString = ""
			}
			path = path.replacingOccurrences(of: "href=\"", with: prefixReplacementString)
			
			// Strip target attribute suffix
			path = path.replacingOccurrences(of: "\" target=\"", with: "/")
			
			sampleURLPaths.append(path)
		}
		
		var sampleArchivePaths : [String] = []
		for urlPath in sampleURLPaths {
			let jsonText = getStringContent(fromURL: urlPath + "book.json")
			if let data = jsonText.data(using: .utf8) {
				let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
				if let dictionary = object as? [String:Any] {
					if let relativePath = dictionary["sampleCode"] as? String {
						sampleArchivePaths.append(urlPath + relativePath)
					}
				}
			}
		}
		
		return sampleArchivePaths
	}
	
	class func getSampleCodeURL2(fromHTML: String) -> [String] {
//		let pat = "\\b.*(http(?:s)?://.*\\.zip)\\b"
		let pat = "(http(?:s)?[^ ]*?\\.zip)"
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		
		var sampleURLPaths : [String] = []
		for match in matches {
			let range = match.range(at: 1)
			let path = (fromHTML as NSString).substring(with: range)
			sampleURLPaths.append(path)
		}
		
		return sampleURLPaths
	}

	class func getSampleCodeURL3(fromHTML: String) -> [String] {
//		let pat = "(href=\"[^ ]*?/content/samplecode/.*?=\")"
		let pat = "href=\"([^ ]*?/documentation/.*?)\""
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		var sampleURLPaths : [String] = []
		for match in matches {
			let range = match.range(at: 1)
			var path = (fromHTML as NSString).substring(with: range)
			
			// Tack on the hostname if it's not already there (some URLs are listed as
			// relative URL while some are fully-qualified).
			let prefixReplacementString: String
			if !path.contains("href=\"http") {
				prefixReplacementString = "http(?:s)?://developer.apple.com"
			} else {
				prefixReplacementString = ""
			}
			path = path.replacingOccurrences(of: "href=\"", with: prefixReplacementString)
			
			// Strip target attribute suffix
			path = path.replacingOccurrences(of: "\" target=\"", with: "/")
			
			sampleURLPaths.append(path)
		}
		
		var sampleArchivePaths : [String] = []
		for urlPath in sampleURLPaths {
			let htmlText = getStringContent(fromURL: urlPath)

			let pat = "href=\"([^ ]*?/published/.*?.zip)\""
			let regex = try! NSRegularExpression(pattern: pat, options: [])
			let matches = regex.matches(in: htmlText, options: [], range: NSRange(location: 0, length: htmlText.count))
			for match in matches {
				let range = match.range(at: 1)
				let path = (htmlText as NSString).substring(with: range)
				
				sampleArchivePaths.append(path)
			}
			
		}
		
		return sampleArchivePaths
	}
	
	
	class func getStringContent(fromURL: String) -> (String) {
		/* Configure session, choose between:
		* defaultSessionConfiguration
		* ephemeralSessionConfiguration
		* backgroundSessionConfigurationWithIdentifier:
		And set session-wide properties, such as: HTTPAdditionalHeaders,
		HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
		*/
		
		/* Create session, and optionally set a URLSessionDelegate. */
		let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
		
		/* Create the Request:
		My API (2) (GET https://developer.apple.com/videos/play/wwdc2017/201/)
		https://developer.apple.com/videos/play/wwdc2017/102/
		*/
		var result = ""
		guard let URL = URL(string: fromURL) else {return result}
		var request = URLRequest(url: URL)
		request.httpMethod = "GET"
		
		/* Start a new Task */
		let semaphore = DispatchSemaphore.init(value: 0)
		let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
			if (error == nil) {
				/* Success */
				// let statusCode = (response as! NSHTTPURLResponse).statusCode
				// print("URL Session Task Succeeded: HTTP \(statusCode)")
				if let data = data, let string = String.init(data: data, encoding:
					.utf8) {
					result = string

				}
			}
			else {
				/* Failure */
				print("URL Session Task Failed: %@", error!.localizedDescription);
			}
			
			semaphore.signal()
		})
		task.resume()
		semaphore.wait()
		return result
	}
	
	class func downloadFile(urlString: String, forSession sessionIdentifier: String = "???") {
		var fileName = URL(fileURLWithPath: urlString).lastPathComponent
		
		if fileName.hasPrefix(sessionIdentifier) == false {
			fileName = "\(sessionIdentifier)_\(fileName)"
		}
		
		guard !FileManager.default.fileExists(atPath: "./" + fileName) else {
			print("\(fileName): already exists, nothing to do!")
			return
		}
		
		print("[Session \(sessionIdentifier)] Getting \(fileName) (\(urlString)):")
		
		guard URL(string: urlString) != nil else {
			print("<\(urlString)> is not valid URL!")
			return
		}
		
		//		DownloadSessionManager.sharedInstance.downloadFile(fromURL: url, toPath: "\(fileName)")
	}
	
}


class Reachability {
	class func isConnectedToNetwork() -> Bool {
		guard let flags = getFlags() else { return false }
		let isReachable = flags.contains(.reachable)
		let needsConnection = flags.contains(.connectionRequired)
		return (isReachable && !needsConnection)
	}
	
	class func getFlags() -> SCNetworkReachabilityFlags? {
		guard let reachability = ipv4Reachability() ?? ipv6Reachability() else {
			return nil
		}
		var flags = SCNetworkReachabilityFlags()
		if !SCNetworkReachabilityGetFlags(reachability, &flags) {
			return nil
		}
		return flags
	}
	
	class func ipv6Reachability() -> SCNetworkReachability? {
		var zeroAddress = sockaddr_in6()
		zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
		zeroAddress.sin6_family = sa_family_t(AF_INET6)
		
		return withUnsafePointer(to: &zeroAddress, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
				SCNetworkReachabilityCreateWithAddress(nil, $0)
			}
		})
	}
	
	class func ipv4Reachability() -> SCNetworkReachability? {
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		return withUnsafePointer(to: &zeroAddress, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
				SCNetworkReachabilityCreateWithAddress(nil, $0)
			}
		})
	}
}
