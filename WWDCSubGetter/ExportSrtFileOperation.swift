/*
  ExportSrtFilesOperation.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/20/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract: This files export srt files
*/

import Foundation

/// A subclass of Operation which executes `exportSrtFile()` method for input subtitle.
final class ExportSrtFileOperation: Operation {
    
    let subtitle: Subtitle
    
    /// - parameter subtitle: subtitle we want execute it's `exportSrtFile()` method.
    init(subtitle: Subtitle) {
        self.subtitle = subtitle
        super.init()
        name = "Export Srt File"
    }
    
    
    override func execute() {
        
        let subtitle = model.subtitle(for: self.subtitle.id)!

        subtitle.exportSrtFile()
        finish()
    }
}
