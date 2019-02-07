/*
Subtitle.swift
WWDC.srt

Created by Seyed Samad Gholamzadeh on 7/24/1396 AP.
Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
This file contains `Webvtt` and `Subtitle` structs.
*/

import Foundation

// MARK: -  Webvtt

/**
A struct for saving webvtt file informations, such as `name` and `number`
of it in m3u8 file and the webvtt file content(after converting to srt stadard content).
*/
struct Webvtt: Comparable {
	
	/// number of webvtt file in m3u8 file
	var number: Int
	
	/// content of webvtt file
	var content: String
	
	/// name of webvtt file in m3u8 file
	var name: String
}

// We need to just compare `Webvtt`s according to their number, to sort in `Subtitle` webvtts array.
func <(lhs: Webvtt, rhs: Webvtt) -> Bool {
	return lhs.number < rhs.number
}

func ==(lhs: Webvtt, rhs: Webvtt) -> Bool {
	return lhs.number == rhs.number
}

// MARK: -  Subtitle

/// A struct for saving and managing video link informations.
struct Subtitle: Comparable {
	
	/// This is the pattern we use to verify valid WWDC Video links.
	private let pattern = "(http(?:s)?:\\/\\/devstreaming[\\S\\w]*.apple.com\\/videos\\/[wdctuiorals]+\\/)(\\d+)(\\/\\w+\\/)(\\w+)(\\/)(\\w+(?:-)?\\w+)\\.m[op4][v4](?:\\?dl\\=1)?"
	
	
	/// A prefix of inputed video url which used for geting m3u8 and webvtt files url
	private let videoURLPrefix: String
	
	private let wwdcYear: Int
	private let sessionNumber: Int
	
	var webvtts: [Webvtt] = []
	
	/// The given WWDC Video download url
	let videoURL: String
	
	/// The given WWDC Video name
	let videoName: String
	
	/*
	We export subtitles for both SD and HD version of videos.
	So we have subtitle name property for each of them.
	*/
	
	/// Subtitle name for HD version of WWDC Video
	private var subtitleNameForHD: String {
		return self.videoName + ".srt"
	}
	
	/// Subtitle name for SD version of WWDC Video
	private var subtitleNameForSD: String {
		return self.subtitleNameForHD.replace("_hd_", with: "_sd_").replace("-HD", with: "-SD").replace("_hd.", with: "_sd.")
	}
	
	/// The url that used to download subtitle m3u8 file
	var m3u8URL: URL {
		return URL(string:self.videoURLPrefix + "subtitles/eng/prog_index.m3u8")!
	}
	
	/// The id used to save subtitle in the model
	var id: ID {
		return Int("\(wwdcYear)\(sessionNumber)")!
	}
	
	/// We Check validation of inputed WWDC video url and if it wasn't valid we return nil in initialization.
	/// - parameter videoURL: WWDC video url which want to export its subtitle.
	init?(videoURL: String) {
		
		if let regexGroup = videoURL.captureGroups(with: pattern), !regexGroup.isEmpty {
			/*
			If video url was valid we export some information from video url
			like video name , wwdc year, session number,... and save them to
			related properties.
			*/
			self.videoURL = regexGroup[0]
			self.videoURLPrefix = regexGroup[1...5].joined()
			self.videoName = regexGroup[6]
			self.wwdcYear = Int(regexGroup[2])!
			self.sessionNumber = Int(regexGroup[4]) ?? {
				
				/*
				Some video links group 4 of pattern is'nt session number,
				so we should get the session number in other ways.
				If we failed to get session number in any way so we
				return a randomNumber as session number.
				- note: this number isn't use anywhere in exported srt file.
				*/
				func randomNumber() -> Int {
					return Int(arc4random_uniform(100))*Int(arc4random_uniform(101))
				}
				
				if let group = regexGroup[3].captureGroups(with: "\\/(\\d+)\\w+\\/") {
					if let number = Int(group[1]) {
						return number
					}
					else {
						return randomNumber()
					}
				}
				else {
					return randomNumber()
				}
				}()
			
		}
		else {
			return nil
		}
	}
	
	
	/// This method gives url for download webvtt file related to given webvtt.
	func url(for webvtt: Webvtt) -> URL {
		let webvttFileURL = self.videoURLPrefix + "subtitles/eng/" + webvtt.name
		return URL(string: webvttFileURL)!
	}
	
	/**
	This method exports srt files with ordering webvtts in webvtts array
	and gatherin their contents in a single srt file.
	*/
	func exportSrtFile() {
		var subString: String = ""
		let array = self.webvtts.sorted()
		for Webvtt in array {
			subString += Webvtt.content
		}
		
		// Some of webvtts have some joint content. we need found this joint parts and delete them.
		var subArray = subString.components(separatedBy: "\n\n")
		subArray = subArray.removingDuplicates()
		subString = subArray.filter{!$0.isEmpty}.map{"\(subArray.index(of: $0)! + 1)\n" + $0 }.joined(separator: "\n\n\n") + "\n\n"
		self.saveSrtFileAtDestination(with: subString)
		SubtitlesProgress.changed()
	}
	
	/**
	This method saves given text as content of exported subtitle in a srt files.
	
	- note: We save two srt file in local url for both SD and HD versions of WWDC video.
	
	- parameter text: The content that should save in srt file.
	*/
	private func saveSrtFileAtDestination(with text: String) {
		
		if let dir = model.destinationURL {
			
			//writing
			do {
				let folderPathHD = "/WWDC_\(self.wwdcYear)_Video_Subtitles/HD/"
				let folderPathSD = "/WWDC_\(self.wwdcYear)_Video_Subtitles/SD/"
				try FileManager.default.createDirectory(atPath: dir.path + folderPathHD, withIntermediateDirectories: true, attributes: nil)
				try FileManager.default.createDirectory(atPath: dir.path + folderPathSD, withIntermediateDirectories: true, attributes: nil)
				
				var path = dir.appendingPathComponent(folderPathHD + subtitleNameForHD)
				try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
				
				path = dir.appendingPathComponent(folderPathSD + subtitleNameForSD)
				try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
				
			}
			catch {/* error handling here */
				print(error.localizedDescription)
			}
		}
	}
	
	func getARandomNumber() -> Int {
		return Int(arc4random_uniform(100))*Int(arc4random_uniform(101))
	}
	
}


// We need to just compare `Subtitle`s according to their id, to sort in `Subtitle` webvtts array.
func <(lhs: Subtitle, rhs: Subtitle) -> Bool {
	return lhs.id < rhs.id
}

func ==(lhs: Subtitle, rhs: Subtitle) -> Bool {
	return lhs.id == rhs.id
}
