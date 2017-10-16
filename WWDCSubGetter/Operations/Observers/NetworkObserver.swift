/*
  NetworkObserver.swift
  MyOperationPractice

  Created by Seyed Samad Gholamzadeh on 7/14/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     Contains the code to manage the visibility of the network activity indicator
*/

import UIKit

/**
     An `OperationObserver` that will cause the network activity indicatior to appear as long
     as the `Operation` to which it is attached is executing.
*/

struct NetworkObserver: OperationObserver {
    //MARk: Initialization
    
    init() { }
    
    func operationDidStart(_ operation: Operation) {
        DispatchQueue.main.async {
            // Increment the network indicator's "reference count"
            NetworkIndicatorController.shared.networkActivityDidStart()
        }
    }
    
    func operation(_ operation: Operation, didProduceOperation newOperation: Foundation.Operation) { }
    
    func operationDidFinish(_ operation: Operation, errors: [NSError]) {
        DispatchQueue.main.async {
            // Decrement the network indicator's "reference count".
            NetworkIndicatorController.shared.networkActivityDidEnd()
        }
    }
}


/// A singleton to manage a visual "reference count" on the network activity indicator.
private class NetworkIndicatorController {
    // MARK: Properties
    
    static let shared = NetworkIndicatorController()
    
    fileprivate var activityCount = 0
    
    fileprivate var visibilityTimer: Timer?
    
    // MARK: Methods
    
    func networkActivityDidStart() {
        assert(Thread.isMainThread, "Alerting network activity indicator state can only be done on the main thread.")
        
        activityCount += 1
        
        updateIndicatorVisibility()
    }
    
    func networkActivityDidEnd() {
        assert(Thread.isMainThread, "Alerting network activity indicator state can only be done on the main thread.")
        
        activityCount -= 1
        
        updateIndicatorVisibility()
    }
    
    func updateIndicatorVisibility() {
        if activityCount > 0 {
            showIndicator()
        }
        else {
            /*
                 To perevent the indicator from flickering on and off, we delay the hiding
                 of the indicator by one second. This provides the chance to come in and
                 invalidate the timer before it fires.
            */
            visibilityTimer = Timer(interval: 1.0) {
                self.hideIndicator()
            }
        }
    }
    
    fileprivate func showIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    fileprivate func hideIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


/// Essentially a cancelable `dispatch_after`.
class Timer {
    //MARK: Properties
    
    fileprivate var isCancelled = false
    
    //MARK: Initialiazation
    
    init(interval: TimeInterval, handler: @escaping () -> Void) {
        let when = DispatchTime.now() + Double(Int64(interval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
            if self?.isCancelled == false {
                handler()
            }
        }
    }
    
    func cancel() {
        isCancelled = true
    }
}
