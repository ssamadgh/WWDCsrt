//
//  Webvtt.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 9/14/23.
//  Copyright © 2023 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

// MARK: -  Webvtt

/**
A struct for saving webvtt file informations, such as `name` and `number`
of it in m3u8 file and the webvtt file content(after converting to srt stadard content).
*/
struct Webvtt: Comparable {
    
    /// number of webvtt file in m3u8 file
    var number: Int
    
    /// content of webvtt file
    var content: String
    
    /// name of webvtt file in m3u8 file
    var name: String
}

// We need to just compare `Webvtt`s according to their number, to sort in `Subtitle` webvtts array.
func <(lhs: Webvtt, rhs: Webvtt) -> Bool {
    return lhs.number < rhs.number
}

func ==(lhs: Webvtt, rhs: Webvtt) -> Bool {
    return lhs.number == rhs.number
}
