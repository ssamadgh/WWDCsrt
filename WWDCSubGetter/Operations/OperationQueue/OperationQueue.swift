/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This file contains an NSOperationQueue subclass.
 */

import Foundation

/**
 The delegate of an `OperationQueue` can respond to `Operation` lifecycle
 events by implementing these methods.
 
 In general, implementing `OperationQueueDelegate` is not necessary; you would
 want to use an `OperationObserver` instead. However, there are a couple of
 situations where using `OperationQueueDelegate` can lead to simpler code.
 For example, `GroupOperation` is the delegate of its own internal
 `OperationQueue` and uses it to manage dependencies.
 */
@objc protocol OperationQueueDelegate: NSObjectProtocol {
    @objc optional func operationQueue(_ operationQueue: OperationQueue, willAddOperation operation: Foundation.Operation)
    @objc optional func operationQueue(_ operationQueue: OperationQueue, operationDidFinish operation: Foundation.Operation, withErrors errors: [NSError])
}

/**
 `OperationQueue` is an `NSOperationQueue` subclass that implements a large
 number of "extra features" related to the `Operation` class:
 
 - Notifying a delegate of all operation completion
 - Extracting generated dependencies from operation conditions
 - Setting up dependencies to enforce mutual exclusivity
 */
class OperationQueue: Foundation.OperationQueue {
    weak var delegate: OperationQueueDelegate?
    
    override func addOperation(_ op: Foundation.Operation) {
        if let op = op as? Operation {
            // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
            let delegate = BlockObserver(
                startHandler: nil,
                produceHandler: { [weak self] in
                    self?.addOperation($1)
                },
                finishHandler: { [weak self] in
                    if let q = self {
                        q.delegate?.operationQueue?(q, operationDidFinish: $0, withErrors: $1)
                    }
                }
            )
            op.addObserver(delegate)
            
            // Extract any dependencies needed by this operation.
            let dependencies = op.conditions.compactMap {
                $0.dependencyForOperation(op)
            }
            
            for dependency in dependencies {
                op.addDependency(dependency)
                
                self.addOperation(dependency)
            }
            
            /*
             With condition dependencies added, we can now see if this needs
             dependencies to enforce mutual exclusivity.
             */
            let concurrencyCategories: [String] = op.conditions.compactMap { condition in
                if !type(of: condition).isMutuallyExclusive { return nil }
                
                return "\(type(of: condition))"
            }
            
            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.shared
                
                exclusivityController.addOperation(op, categories: concurrencyCategories)
                
                op.addObserver(BlockObserver(finishHandler:  { operation, _ in
                    exclusivityController.removeOperation(operation, categories: concurrencyCategories)
                }))
            }
            
            /*
             Indicate to the operation that we've finished our extra work on it
             and it's now it a state where it can proceed with evaluating conditions,
             if appropriate.
             */
            op.willEnqueue()
        }
        else {
            /*
             For regular `NSOperation`s, we'll manually call out to the queue's
             delegate we don't want to just capture "operation" because that
             would lead to the operation strongly referencing itself and that's
             the pure definition of a memory leak.
             */
            op.addCompletionBlock { [weak self, weak op] in
                guard let queue = self, let operation = op else { return }
                queue.delegate?.operationQueue?(queue, operationDidFinish: operation, withErrors: [])
            }
        }
        
        delegate?.operationQueue?(self, willAddOperation: op)

        super.addOperation(op)
    }
    
    override func addOperations(_ ops: [Foundation.Operation], waitUntilFinished wait: Bool) {
        /*
         The base implementation of this method does not call `addOperation()`,
         so we'll call it ourselves.
         */
        for operation in ops {
            addOperation(operation)
        }
        
        if wait {
            for operation in ops {
                operation.waitUntilFinished()
            }
        }
    }
}

