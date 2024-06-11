//
//  WWDC2020.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 9/14/23.
//  Copyright © 2023 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

struct WWDC2020: WWDCYear {
    let pattern: String = "(http(?:s)?:\\/\\/devstreaming[\\S\\w]*.apple.com\\/videos\\/[wdctuiorals]+\\/)(\\d+)(\\/)(\\d+)(\\/\\d+\\/)([a-zA-Z0-9\\-]+\\/)([a-zA-Z0-9\\-\\_]+)\\.m[op4][v4](?:\\?dl\\=1)?"
    
    let videoURLPrefix: String
    
    let sessionNumber: Int
    
    let year: String
    
    let videoURL: String
    
    let videoName: String
    
    var subtitleNameForHD: String {
        return self.videoName + ".srt"
    }
    
    var subtitleNameForSD: String {
        return self.subtitleNameForHD.replace("_hd.", with: "_sd.")
    }
    
    var m3u8URL: URL {
        return URL(string: self.videoURLPrefix + "cc/en/en.m3u8")!
    }
    
    var id: ID {
        return Int("\(year)\(sessionNumber)")!
    }
    
    func url(for webvtt: Webvtt) -> URL {
        return URL(string: self.videoURLPrefix + "cc/en/" + webvtt.name)!
    }
    
    var webvtts: [Webvtt] = []
    
    init?(videoURL: String) {
        let regexGroup = videoURL.captureGroups(with: pattern)!
        if !regexGroup.isEmpty  {
            /*
             If video url was valid we export some information from video url
             like video name , wwdc year, session number,... and save them to
             related properties.
             */
            
            self.videoURL = regexGroup[0]
            self.videoURLPrefix = regexGroup[1...6].joined()
            self.videoName = regexGroup[7]
            self.year = String(regexGroup[2])
            let localSessionNumber = regexGroup[4]
            
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
    
    
    /*
     var subsURLArray = string.components(separatedBy: "\n").filter {$0.contains("fileSequence")}
     if self.subtitle.wwdcYear >= 2021 {
     subsURLArray = string.components(separatedBy: "\n").filter {$0.contains("sequence")}
     }
     */
    mutating func updateWebvtts(with url: URL) throws {
        /*
         We convert m3u8 file to an arry of `Webvtt` objects,
         which are the original subtitle files.
         We download and convert this webvtt files in a single srt file later.
         */
        let string = try String(contentsOf: url, encoding: String.Encoding.utf8)
        let subsURLArray = string.components(separatedBy: "\n").filter {$0.contains("fileSequence")}
        
        
        let webvttArray = subsURLArray.map {Webvtt(number: subsURLArray.firstIndex(of: $0)!, content: "", name: $0)}
        self.webvtts = webvttArray
    }
    
    
}
