//
//  App.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation
import Async

final class App {
    
    
    private let config: Configuration
    private let eventLoops: [EventLoop]
    
    public init(_ configuration: Configuration) throws {
        
        guard configuration.tasks.count > 0 else {
            throw SwiftQError.tasksNotRegistered
        }
        
        guard configuration.concurrency > 0 else {
            throw SwiftQError.invalidConcurrency(configuration.concurrency)
        }
        
        guard configuration.queue.count > 0 else {
            throw SwiftQError.invalidQueueName(configuration.queue)
        }
        
        if configuration.redisConfig.password == nil {
            Logger.warning("Insecure redis configuration, always set a password")
        }
        
        self.config = configuration
        // FIXME: Specify event loop type.
        self.eventLoops = (1...configuration.concurrency).map { num -> DispatchEventLoop in
            let eventLoop =  DispatchEventLoop(label: "swiftQ.eventloop.\(num)")
            return eventLoop
        }
        
    }
    
    public func run() throws {
        _ = try eventLoops.map { eventLoop in
            return try Consumer(config, on: eventLoop)
        }
        
        RunLoop.main.run()
    }
    
}
