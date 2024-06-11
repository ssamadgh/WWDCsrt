/*
Subtitle.swift
WWDC.srt

Created by Seyed Samad Gholamzadeh on 7/24/1396 AP.
Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
This file contains `Webvtt` and `Subtitle` structs.
*/

import Foundation

// MARK: -  Subtitle

struct Subtitle: Comparable {
    
    var id: ID {
        wwdcYear.id
    }
    
    var m3u8URL: URL {
        wwdcYear.m3u8URL
    }
    
    var videoURL: String {
        wwdcYear.videoURL
    }
    
    var webvtts: [Webvtt] {
        wwdcYear.webvtts
    }
    
    var wwdcYear: WWDCYear
    
    init?(videoURL: String, wwdc: WWDC) {
        
        let wwdcYear: WWDCYear? = {
           
            switch wwdc {
            case .of2024, .of2023, .of2022, .of2021:
                return WWDC2021(videoURL: videoURL)
            case .of2020:
                return WWDC2020(videoURL: videoURL)
            default:
                return WWDC2019(videoURL: videoURL)
            }
        }()
        
        guard let wwdcYear = wwdcYear else {
            return nil
        }
        
        self.wwdcYear = wwdcYear
    }
    
    mutating func updateWebvtts(with url: URL) throws {
        try wwdcYear.updateWebvtts(with: url)
    }
    
    func url(for webvtt: Webvtt) -> URL {
        wwdcYear.url(for: webvtt)
    }
    
    /**
    This method exports srt files with ordering webvtts in webvtts array
    and gatherin their contents in a single srt file.
    */
    func exportSrtFile() {
        var subString: String = ""
        let array = self.wwdcYear.webvtts.sorted()
        for Webvtt in array {
            subString += Webvtt.content
        }
        
        // Some of webvtts have some joint content. we need found this joint parts and delete them.
        var subArray = subString.components(separatedBy: "\n\n")
        subArray = subArray.removingDuplicates()
        subString = subArray.filter{!$0.isEmpty}.map{"\(subArray.firstIndex(of: $0)! + 1)\n" + $0 }.joined(separator: "\n\n\n") + "\n\n"
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
                let folderPathHD = "/WWDC_\(self.wwdcYear.year)_Video_Subtitles/HD/"
                let folderPathSD = "/WWDC_\(self.wwdcYear.year)_Video_Subtitles/SD/"
                let hdPath = dir.path + folderPathHD
                let sdPath = dir.path + folderPathSD
                try FileManager.default.createDirectory(atPath: hdPath, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.createDirectory(atPath: sdPath, withIntermediateDirectories: true, attributes: nil)
                
                var path = dir.appendingPathComponent(folderPathHD + wwdcYear.subtitleNameForHD)
                try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                
                path = dir.appendingPathComponent(folderPathSD + wwdcYear.subtitleNameForSD)
                try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                
            }
            catch {/* error handling here */
                print(error.localizedDescription)
            }
        }
    }
    
    mutating func appendWebvtt(_ webvtt: Webvtt) {
        wwdcYear.webvtts.append(webvtt)
    }
    
    mutating func clearWebvtts() {
        wwdcYear.webvtts.removeAll()
    }
    
}

// We need to just compare `Subtitle`s according to their id, to sort in `Subtitle` webvtts array.
func <(lhs: Subtitle, rhs: Subtitle) -> Bool {
    return lhs.wwdcYear.id < rhs.wwdcYear.id
}

func ==(lhs: Subtitle, rhs: Subtitle) -> Bool {
    return lhs.wwdcYear.id == rhs.wwdcYear.id
}


/// A struct for saving and managing video link informations.
struct OldSubtitle: Comparable {
	
	/// This is the pattern we use to verify valid WWDC Video links.
	private let pattern = "(http(?:s)?:\\/\\/devstreaming[\\S\\w]*.apple.com\\/videos\\/[wdctuiorals]+\\/)(\\d+)(\\/\\w+\\/)(\\w+)(\\/)(\\w+(?:-)?\\w+)\\.m[op4][v4](?:\\?dl\\=1)?"

    private let pattern2020 = "(http(?:s)?:\\/\\/devstreaming[\\S\\w]*.apple.com\\/videos\\/[wdctuiorals]+\\/)(\\d+)(\\/)(\\d+)(\\/\\d+\\/)([a-zA-Z0-9\\-]+\\/)([a-zA-Z0-9\\-\\_]+)\\.m[op4][v4](?:\\?dl\\=1)?"

    private let pattern2021 = "(http(?:s)?:\\/\\/devstreaming[\\S\\w]*.apple.com\\/videos\\/[wdctuiorals]+\\/)(\\d+)(\\/)(\\d+)(\\/\\d+\\/)([a-zA-Z0-9\\-]+\\/)(downloads\\/)([a-zA-Z0-9\\-\\_]+)\\.m[op4][v4](?:\\?dl\\=1)?"
	
	/// A prefix of inputed video url which used for geting m3u8 and webvtt files url
	private let videoURLPrefix: String

	private let sessionNumber: Int

	var webvtts: [Webvtt] = []

    let wwdcYear: Int

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
        if self.wwdcYear == 2020 {
            return URL(string: self.videoURLPrefix + "cc/en/en.m3u8")!
        }
		return URL(string:self.videoURLPrefix + "subtitles/eng/prog_index.m3u8")!
	}
	
	/// The id used to save subtitle in the model
	var id: ID {
		return Int("\(wwdcYear)\(sessionNumber)")!
	}
	
	/// We Check validation of inputed WWDC video url and if it wasn't valid we return nil in initialization.
	/// - parameter videoURL: WWDC video url which want to export its subtitle.
	init?(videoURL: String) {
		let regexGroup = videoURL.captureGroups(with: pattern)!
        let regexGroup2020 = videoURL.captureGroups(with: pattern2020)!
        let regexGroup2021 = videoURL.captureGroups(with: pattern2021)!
        if !regexGroup.isEmpty || !regexGroup2020.isEmpty || !regexGroup2021.isEmpty  {
			/*
			If video url was valid we export some information from video url
			like video name , wwdc year, session number,... and save them to
			related properties.
			*/
            var localSessionNumber = ""
            if !regexGroup.isEmpty {
                self.videoURL = regexGroup[0]
                self.videoURLPrefix = regexGroup[1...5].joined()
                self.videoName = regexGroup[6]
                self.wwdcYear = Int(regexGroup[2])!
                localSessionNumber = regexGroup[4]

            } else if !regexGroup2020.isEmpty {
                self.videoURL = regexGroup2020[0]
                self.videoURLPrefix = regexGroup2020[1...6].joined()
                self.videoName = regexGroup2020[7]
                self.wwdcYear = Int(regexGroup2020[2])!
                localSessionNumber = regexGroup2020[4]

            } else {
                self.videoURL = regexGroup2021[0]
                self.videoURLPrefix = regexGroup2021[1...6].joined()
                self.videoName = regexGroup2021[8]
                self.wwdcYear = Int(regexGroup2021[2])!
                localSessionNumber = regexGroup2021[4]
            }

			self.sessionNumber = Int(localSessionNumber) ?? {
				
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
        if self.wwdcYear == 2020 {
            return URL(string: self.videoURLPrefix + "cc/en/" + webvtt.name)!
        }
        return URL(string: self.videoURLPrefix + "subtitles/eng/" + webvtt.name)!
	}
	
	
}


// We need to just compare `Subtitle`s according to their id, to sort in `Subtitle` webvtts array.
func <(lhs: OldSubtitle, rhs: OldSubtitle) -> Bool {
	return lhs.id < rhs.id
}

func ==(lhs: OldSubtitle, rhs: OldSubtitle) -> Bool {
	return lhs.id == rhs.id
}
