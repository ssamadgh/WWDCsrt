//
//  WWDCYear.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 9/14/23.
//  Copyright © 2023 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

protocol WWDCYear {
    
    var pattern: String { get }
    
    var webvtts: [Webvtt] { get set }
    
    var videoURLPrefix: String { get }
    
    var sessionNumber: Int { get }
    
    var year: String { get }
    
    var videoURL: String { get }
    
    var videoName: String { get }
    
    var subtitleNameForHD: String { get }
    
    var subtitleNameForSD: String { get }
    
    var m3u8URL: URL { get }

    var id: ID { get }
    
    func url(for webvtt: Webvtt) -> URL
    
    mutating func updateWebvtts(with url: URL) throws
}
