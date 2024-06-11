/*
  VerifyVideoURLCondition.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     In this file we convert wwdc video links to `Subtitle` objects.
*/

import Foundation

/**
 This enum is for detecting input url type. We have Two types of input for video links.
 A single video link and tex file with a bunch of video links.
*/
enum InputType {
    case textFile
    case videoLink
}

/// An `Operation` for validate the wwdc video links and convert them to `Subtitle`.
final class ConvertToSubtitleOperation: Operation {
    
    let url: String
    let wwdc: WWDC
    let type: InputType
    var completion: (([Subtitle]) -> Void)!

    init(from url: String, wwdc: WWDC, type: InputType) {
        self.url = url
        self.wwdc = wwdc
        self.type = type
        
        super.init()
        self.name = "ConvertToSubtitleOperation"
    }
    
    convenience init(from url: String, wwdc: WWDC, type: InputType, completion: @escaping ([Subtitle]) -> Void) {
        self.init(from: url, wwdc: wwdc, type: type)
        self.completion = completion

    }
    
    override func execute() {
        
        /*
          We check validation of video links in each type seperately and put back `Subtitle`
         objects of validate links
        */
        
        switch self.type {
        case .videoLink:
            
            let pattern = ".m[op4][v4]"
            if url.contains(pattern) {
                let url = self.url.trimmingCharacters(in: .whitespacesAndNewlines)
                model.createSubtitle(with: url, wwdc: wwdc)
            }
            
        case .textFile:
            let array = convertTextFileToArray()
            for url in array {
                let url = url.trimmingCharacters(in: .whitespacesAndNewlines)
                model.createSubtitle(with: url, wwdc: wwdc)
            }
        }
        
        let subtitlesArray = model.allSubtitles()
        completion(subtitlesArray)
        model.clear()
        finish()
    }
    
    /**
         This method converts text file to an array of video links were inside of text file.
         it also checks if the link is realy blong to a video and filters true links.
    */
    func convertTextFileToArray() -> [String] {
        
        do {
            
            // This solution assumes  you've got the file in your bundle
            
            let data = try String(contentsOfFile:url, encoding: String.Encoding.utf8)
            let pattern = ".m[op4][v4]"
            let videosURLArray = data.components(separatedBy: "\n").filter {$0.contains(pattern)}
            
            return videosURLArray
            
        } catch {
            
            // do something with Error
            print(error.localizedDescription)
        }
        return []
    }
    
}

