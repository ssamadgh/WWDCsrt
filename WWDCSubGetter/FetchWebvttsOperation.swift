/*
  DownloadWebvttsOperation.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This file fetches webvtt files related to each subtitle
*/

import Foundation

     ///A compose Operation to fetch webvtts files for input subtitle concurrently.
final class FetchWebvttsOperation: GroupOperation {
    
    var subtitle: Subtitle
    
    /// - parameter subtitle: The subtitle which we want to fetch its webvtt files.
    init(subtitle: Subtitle) {
        self.subtitle = subtitle
        
        super.init(operations: [])
        name = "Fetch Webvtts"
        
        // We limit maximum of concurrent operations to avoid of creating too many operations  for a bunch of Webvtt links
        self.limitMaxConcurrentOperations(to: 3)

    }
    
    /*
     We create child operations and add them to queue in `execute()` method instead of in `init(...)`.
     its because when we initialize this operation in `FetchSubtitlesOperation`,
     we don't have webvtts in subtitles `webvtts` array, so we must wait to
     download subtitle's m3u8 file and making webvtts, and then create webvtts
     download operations.
     */

    override func execute() {
        
        /*
             Because Subtite is a struct and is a value type, we need to invoke it in `execute()` method
             to have an updated version of it
        */
        let sub = model.subtitle(for: self.subtitle.id)!
        let webvttArray = sub.webvtts
        
        for webvtt in webvttArray {
            
            let downloadOperation = DownloadWebvttOperation(subtitle: sub, webvtt: webvtt)
            addOperation(downloadOperation)
        }
        
        // We clear subtitle webvtts array, because after downloading webvtts, we fill this array we new webvtts.
        model.clearWebvttArray(of: sub)
        
        super.execute()
    }
    
}
