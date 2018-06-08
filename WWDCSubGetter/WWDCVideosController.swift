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
	
	class func getHDorSDdURLs(fromHTML: String, format: VideoQuality) -> (String) {

		let formatValue = format == .hd ? "[hH][dD]" : "[sS][dD]"
		
		let pat = "\\b.*(http(?:s)?://.*" + formatValue + ".*\\.m[op4][v4])\\b"

		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		var videoURL = ""
		if !matches.isEmpty {
			let range = matches[0].range(at: 1)
			let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
				fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
			videoURL = String(fromHTML[r])
		}
		
		return videoURL
	}
	
	class func getPDFResourceURL(fromHTML: String) -> [String] {
		let pat = "\\b.*(http(?:s)?://.*\\.pdf)\\b"
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
			let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
				fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
			let path = String(fromHTML[r])
			pdfResourceURLPaths.append(path)
		}
		
		return pdfResourceURLPaths

	}
	
	class func getSampleCodeURL2(fromHTML: String) -> [String] {
		let pat = "\\b.*(http(?:s)?://.*\\.zip)\\b"
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		
		var sampleURLPaths : [String] = []
		for match in matches {
			let range = match.range(at: 1)
			let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
				fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
			let path = String(fromHTML[r])
			sampleURLPaths.append(path)
		}
		
		return sampleURLPaths
	}

	
	
	class func getTitle(fromHTML: String) -> (String) {
		let pat = "<h1>(.*)</h1>"
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		var title = ""
		if !matches.isEmpty {
			let range = matches[0].range(at: 1)
			let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
				fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
			title = String(fromHTML[r])
		}
		
		return title
	}
	
	class func getSampleCodeURL(fromHTML: String) -> [String] {
		let pat = "\\b.*(href=\".*/content/samplecode/.*\")\\b"
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		var sampleURLPaths : [String] = []
		for match in matches {
			let range = match.range(at: 1)
			let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
				fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
			var path = String(fromHTML[r])
			
			// Tack on the hostname if it's not already there (some URLs are listed as
			// relative URL while some are fully-qualified).
			let prefixReplacementString: String
			if path.contains("href=\"http") == false {
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
				if let dictionary = object as? NSDictionary {
					if let relativePath = dictionary["sampleCode"] as? String {
						sampleArchivePaths.append(urlPath + relativePath)
					}
				}
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
				result = String.init(data: data!, encoding:
					.ascii)!
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

	class func getSessionsList(fromHTML: String, wwdcYear: String) -> Array<String> {
		let pat = "\"\\/videos\\/play\\/\(wwdcYear)\\/([0-9]*)\\/\""
		let regex = try! NSRegularExpression(pattern: pat, options: [])
		let matches = regex.matches(in: fromHTML, options: [], range: NSRange(location: 0, length: fromHTML.count))
		var sessionsListArray = [String]()
		for match in matches {
			for n in 0..<match.numberOfRanges {
				let range = match.range(at: n)
				let r = fromHTML.index(fromHTML.startIndex, offsetBy: range.location) ..<
					fromHTML.index(fromHTML.startIndex, offsetBy: range.location+range.length)
				switch n {
				case 1:
					//print(htmlSessionList.substring(with: r))
					sessionsListArray.append(String(fromHTML[r]))
				default: break
				}
			}
		}
		return sessionsListArray
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
		
		guard let url = URL(string: urlString) else {
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
