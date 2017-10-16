/*
  DownloadWebvttOperation.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
 This file contains the code to download the webvtt file.

*/

import Foundation

/**
 An operation to download webvtt file.
 - note: Webvtt files, are bunch of files used for online videos subtitles.
     we download them and cnvert them to a single srt file.
 */
final class DownloadWebvttOperation: GroupOperation {
    
    var subtitle: Subtitle
    var webvtt: Webvtt
    
    init(subtitle: Subtitle, webvtt: Webvtt) {
        self.subtitle = subtitle
        self.webvtt = webvtt
        
        super.init(operations: [])
        name = "Download Webvtt \(webvtt.number)"
        
        let task = URLSession.shared.downloadTask(with: subtitle.url(for: webvtt)) { (url, response, error) in
            if let error = error {
                print(" the operation \(self.name!) of \(subtitle.videoURL) download task faced error : \(error)")
            }
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
                     After download finished, we get the content of webvtt file
                     and convert it to a standard srt subtitle content.
                */
                var content = try String(contentsOf: localURL, encoding: String.Encoding.utf8)
                content = content.replace("WEBVTT", with: "").replace("&gt;", with: ">").replace("&lt;", with: "<").replace("&amp;", with: "&")
                
                let pattern = "\nX-TIMESTAMP-MAP[\\w+:,=.//d+]+\n\n"
                content = content.replace(matches: pattern, with: "")!
                
                let newContent = self.convertWebvttToSrt(webvtt: content)
                webvtt.content = newContent
                
                model.add(self.webvtt, to: self.subtitle)

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
    
    ///This method converts webvtt standard content to srt standard content
    func convertWebvttToSrt(webvtt: String) -> String {
        let timeLinePattern = "([0-9:.]+)\\.(\\d+ --> [0-9:.]+)\\.(\\d+) (\\w+:\\w+)"
        var firstLines:[String] = []
        var newLines:[String] = []
        var newSrt = webvtt
        
        firstLines = webvtt.list(matches: timeLinePattern) ?? []
        
        if !firstLines.isEmpty {
            for line in firstLines {
                
                let groups = line.captureGroups(with: timeLinePattern)!
                
                let newLine: String = groups[1] + "," + groups[2] + "," + groups[3]
                newLines.append(newLine)
            }
            
            for i in 0...firstLines.count-1 {
                newSrt = newSrt.replace(firstLines[i], with: newLines[i])
            }
        }
        return newSrt
    }

    
}
