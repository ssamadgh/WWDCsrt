
/*
 GetSubtitleOperation.swift
 WWDC.srt
 
 Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This file sets up the operations to fetch subtitles from internet. It will also decide to display an error message, if appropriate.
*/

import Cocoa

/// A composite operation for fetching subtitles and clearing model.
final class GetSubtitlesOperation: GroupOperation {
    
    /**
     - parameter completionHandler: The handler to call after fetching and
     clearing model are complete. This handler will be
     invoked on an arbitrary queue.
    */
    init(completionHandler: @escaping () -> Void) {
        
        super.init(operations: [])
        name = "Get Subtitles"

        /*
         This operation is made of three child operations:
         1. The operation to fetch subtitle.
         2. The operation to clear model after fetching ends.
         3. The operation to invoke the completion handler.
         */

        let fetchSubtitlesOperation = FetchSubtitilesOperation()
        let sampleURL = URL(string: "https://www.google.com")!
        let reachabilityCondition = ReachabilityCondition(host: sampleURL)
        fetchSubtitlesOperation.addCondition(reachabilityCondition)

        let clearModelOperation = BlockOperation { (block) in
            model.clear()
            block()
        }
        
        let finishOperation = Foundation.BlockOperation(block: completionHandler)

        
        // These operations must be executed in order
        clearModelOperation.addDependency(fetchSubtitlesOperation)
        finishOperation.addDependency(fetchSubtitlesOperation)

        addOperations([fetchSubtitlesOperation, clearModelOperation, finishOperation])
    }
    
    override func operationDidFinish(_ operation: Foundation.Operation, withErrors errors: [NSError]) {
        guard !errors.isEmpty else { return }
        self.produceAlert(errors.first!)
    }
    
    fileprivate func produceAlert(_ error: NSError) {
        /*
         Here we represent error in viewController.
         We only checks if the error is about reachability condition,
         if not it probably is about problem to find approperiate subtitle
         or failing to downlading it, by the way we alert user
         downlad of some subtitles failed.
         */
        var errorDescription = ""
        if (error.userInfo[OperationConditionKey] as? String) == ReachabilityCondition.name {
            errorDescription = "Error: Can not Connect to internet. Please check your connection!"
        }
        else {
            errorDescription = "Error: Failed to download some subtitles."
        }
        if let presentationContext = NSApplication.shared.keyWindow?.contentViewController as? MainViewController {
            presentationContext.endDownloadingStatus(withError: errorDescription)
        }
        print(error)
    }
    
    
}
