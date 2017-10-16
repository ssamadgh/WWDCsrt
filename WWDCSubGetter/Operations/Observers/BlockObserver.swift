/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This file shows how to implement the OperationObserver protocol.
 */

import Foundation

/**
 The `BlockObserver` is a way to attach arbitrary blocks to significant events
 in an `Operation`'s lifecycle.
 */
struct BlockObserver: OperationObserver {
    // MARK: Properties
    
    fileprivate let startHandler: ((Operation) -> Void)?
    fileprivate let produceHandler: ((Operation, Foundation.Operation) -> Void)?
    fileprivate let finishHandler: ((Operation, [NSError]) -> Void)?
    
    init(startHandler: ((Operation) -> Void)? = nil, produceHandler: ((Operation, Foundation.Operation) -> Void)? = nil, finishHandler: ((Operation, [NSError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(_ operation: Operation) {
        startHandler?(operation)
    }
    
    func operation(_ operation: Operation, didProduceOperation newOperation: Foundation.Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(_ operation: Operation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}

