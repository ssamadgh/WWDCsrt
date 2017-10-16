/*
  TextFileView.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 7/21/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This files contains method for enable drag and drop ability for TextFileView
*/

import Cocoa

/// protocol which called when a true text file dropped to view
protocol TextFileViewDelegate {
    
    func droppedTextFileURL(_ url: URL)
}

/// A subclass of `NSView` which have ability to accept droped files to itself.
final class TextFileView: NSView {
    
    enum Appearance {
        static let lineWidth: CGFloat = 10.0
    }

    var delegate: TextFileViewDelegate?

    override func awakeFromNib() {
        setup()
    }
    
    var acceptableTypes: Set<NSPasteboard.PasteboardType> {
        
        if #available(OSX 10.13, *) {
            
            return [.URL, .fileURL]
            
        } else {
            
            return [NSPasteboard.PasteboardType(rawValue: "public.file-url")]
        }
    }

    func setup() {
        registerForDraggedTypes(Array(acceptableTypes))
    }
    
    // We want just accept files that are text type
    let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSAttributedString.textTypes]
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        //2.
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        //3.
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        return canAccept
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = Appearance.lineWidth
            path.stroke()
        }
    }
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            delegate?.droppedTextFileURL(urls.first!)
            return true
        }
        return false
        
    }
}
