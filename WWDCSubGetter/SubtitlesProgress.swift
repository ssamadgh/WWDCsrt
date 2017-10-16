/*
  SubtitlesProgress.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/24/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
 This file manages progress value of subtitle exporting for showing in `progressIndicator`.
*/

import Cocoa
/**
     We create a property of this protocol in `SubtitleProgress` and conform `MainViewController to this protocol to alert it about changes of subtitle exporting progress status.
*/
protocol ProgressView {
    func progressChanged(to value: Double)
}

/**
     This struct is mediator between `Subtitle` struct and `MainViewController`
     to alert subtitles exporting status, and for this reason it's property and methods
     are static, because we need shared properties and methods for this purpose.
     every subtitle which wants export, calling `SubtitlesProgress.changed()` method of
     this struct, and this struct computes progress value of exporting entire subtitles
     which are in queue.
*/

struct SubtitlesProgress {
    
    static var min: Double = 0
    static var max: Double = 100
    static var current: Double = 0
    static var unit: Double = 1.0
    
    static var progressView: ProgressView?
    
    // Here we compute new value of progress and calling `ProgressView` progressChanged method.
    static func changed() {
        self.current += self.unit
        self.progressView?.progressChanged(to: self.current)
    }
}
