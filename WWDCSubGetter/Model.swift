/*
  Model.swift
  WWDC.srt

  Created by Seyed Samad Gholamzadeh on 6/25/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This file contains struct Model which manages subtitles.
*/

import Foundation

typealias ID = Int

/**
     We created a global instance of `Model`, thus we can manage our subtitles easily
     in every class and struct.
*/

class SafeModel {
    
    var queue = DispatchQueue(label: "Model_Thread_Safe_Queue")
    
    private var _model = Model()

    
    var model: Model {
        get {
            queue.sync {
                return self._model
            }
        }
        
        set {
            queue.async {
                self._model = newValue
            }
        }
    }
    
}

fileprivate var safeModel = SafeModel()

var model: Model {
    get {
        return safeModel.model
    }
    
    set {
        safeModel.model = newValue
    }
}



struct Model {
    
    /// A dictionay that saves subtitles with their id
    private var videosSub: [Int: Subtitle] = [:]
    
    /// The destination Local URL Which subtitles exported there
    var destinationURL: URL?
    
    /// A Boolean value that indicates whether the model is empty.
    var isEmpty: Bool {
        return self.videosSub.isEmpty
    }
    
    /**
         This method create a subtitle object with given `videoURL`
         and if it wasn't nil, adds it to the model.
    */
    mutating func createSubtitle(with videoURL: String, wwdc: WWDC) {
        if let subtitle = Subtitle(videoURL: videoURL, wwdc: wwdc) {
            self.videosSub[subtitle.id] = subtitle
        }
    }
    
    /// This method updates model subtitles, with the given subtitles.
    mutating func update(_ subtitles: [Subtitle]) {
        for subtitle in subtitles {
            self.videosSub[subtitle.id] = subtitle
        }
    }

    /// This method updates model subtitle, with the given subtitle.
    mutating func update(_ subtitle: Subtitle) {
        self.update([subtitle])
    }
    
    /// This method returns subtitle that saved in the model with the given id
    func subtitle(for id: ID) -> Subtitle? {
        return self.videosSub[id]
    }
    
    /// This method returns all subtitles saved in the model.
    func allSubtitles() -> [Subtitle] {
        return self.videosSub.values.sorted()
    }
    
    /// This method adds given webvtt to the specified model subtitle
    mutating func add(_ webvtt: Webvtt, to subtitle: Subtitle) {
        self.videosSub[subtitle.id]?.appendWebvtt(webvtt)
    }
    
    /// This method clears webvttArray of the specified model subtitle
    mutating func clearWebvttArray(of subtitle: Subtitle) {
        self.videosSub[subtitle.id]?.clearWebvtts()
    }
    
    /// This method clears all subtitles saved in the model.
    mutating func clear() {
        self.videosSub.removeAll()
    }
    
}


