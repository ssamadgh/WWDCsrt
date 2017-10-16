//
//  AppDelegate.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 5/22/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                    window.windowController?.showWindow(self)
            }
        }
        
        return true
    }

}

