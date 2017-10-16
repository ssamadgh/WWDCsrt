/*
  FetchSubtitilesOperation.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     In this file we download m3u8 file for each subtitle and fetch webvtt files
     and a th the end we export srt files.
 
*/

import Foundation

/// A composite operation to download m3u8 files, fetching webvtt files and exporting srt file for each `Subtitle` concurrently.
final class FetchSubtitilesOperation: GroupOperation {
    
    
    init() {
        super.init(operations: [])
        name = "FetchSubtitilesOp"
        
        // We limit maximum of concurrent operations to avoid of creating too many operations  for a bunch of video links
        self.limitMaxConcurrentOperations(to: 3)
        
        for subtitle in model.allSubtitles() {
            
            let downloadOperation = DownloadM3U8Operation(subtitle: subtitle)
            let fetchWebvttsOperation = FetchWebvttsOperation(subtitle: subtitle)
            let exportSrtFileOperation = ExportSrtFileOperation(subtitle: subtitle)
            
            exportSrtFileOperation.addDependency(fetchWebvttsOperation)
            fetchWebvttsOperation.addDependency(downloadOperation)
            
            addOperations([downloadOperation, fetchWebvttsOperation, exportSrtFileOperation])
            
        }

        
    }
    
}
