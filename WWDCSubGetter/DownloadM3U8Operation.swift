/*
  DownloadAndMakeSrtOperation.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
 This file contains the code to download the m3u8 file.
*/

import Foundation

/**
     An operation to download m3u8 file for input subtitle.
 - note: A m3u8 file, is a file blong to each video link and contains
     some informations about video subtitle files which are in webvtt format
     and we dwonload them later.
 
*/
final class DownloadM3U8Operation: GroupOperation {
    // MARK: Properties

    var subtitle: Subtitle
    
    /// - parameter subtitle: The subtitle which we want to download its m3u8 file.
    init(subtitle: Subtitle) {
        
        self.subtitle = subtitle
        
        super.init(operations: [])
        name = "Download M3U8"
        
        let task = URLSession.shared.downloadTask(with: subtitle.m3u8URL) { (url, response, error) in
            self.downloadFinished(url, response: response, error: error as NSError?)
            return()
        }

        let taskOperation = URLSessionTaskOperation(task: task)

        addOperation(taskOperation)

    }
    
    func downloadFinished(_ url: URL?, response: URLResponse?, error: NSError?) {
        if let localURL = url {
            
            do {
                
                /*
                 We convert m3u8 file to an arry of `Webvtt` objects,
                 which are the original subtitle files.
                 We download and convert this webvtt files in a single srt file later.
                */
                let string = try String(contentsOf: localURL, encoding: String.Encoding.utf8)
                let subsURLArray = string.components(separatedBy: "\n").filter {$0.contains("fileSequence")}
                let webvttArray = subsURLArray.map {Webvtt(number: subsURLArray.index(of: $0)!, content: "", name: $0)}
                self.subtitle.webvtts = webvttArray
                model.update(self.subtitle)
            }
            catch let error as NSError {
                aggregateError(error)
            }

        }
        else if let error = error {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
        
}
