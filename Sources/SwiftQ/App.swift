//
//  App.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-26.
//

import Foundation
import Async

public final class App {
    
    private let config: Configuration
    private let consumers: [Consumer]
    
    // FIXME: Specify event loop type. KQUEUE, EPOLL, DISPATCH
    public init(with configuration: Configuration) throws {
        
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
        
        self.consumers = try (1...configuration.concurrency).map { num in
            let eventLoop = DispatchEventLoop(label: "swiftQ.eventloop.\(num)")
            return try Consumer(configuration, on: eventLoop)
        }
        
    }
    
    public func run() throws -> Never {
        consumers.forEach { $0.run() }
        
        RunLoop.main.run()
        exit(0)
    }
    
}
