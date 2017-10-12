//
//  SwiftQConsumer.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-04.
//
//

import Foundation
import Dispatch

public final class SwiftQConsumer {
    
    private let worker: Worker
    
    private let monitor: QueueMonitor
    
    private let config: Configuration
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    
    public init(_ configuration: Configuration) throws {
        
        guard configuration.tasks.count > 0 else {
            throw SwiftQError.tasksNotRegistered
        }
        
        guard configuration.concurrency > 0 else {
            throw SwiftQError.invalidConcurrency(configuration.concurrency)
        }
        
        guard configuration.queue.characters.count > 0 else {
            throw SwiftQError.invalidQueueName(configuration.queue)
        }
        
        if configuration.redisConfig.password == nil {
            Logger.warning("Insecure redis configuration, always set a password")
        }
        
        self.config = configuration
        self.worker = try Worker(decoder: Decoder(types: configuration.tasks),
                                 config: configuration.redisConfig,
                                 concurrency: configuration.concurrency,
                                 queue: configuration.queue,
                                 consumerName: configuration.consumerName,
                                 middleware: configuration.middleware)
        let scheduledQueue = try ScheduledQueue(config: configuration.redisConfig)
        self.monitor = QueueMonitor(queues: [scheduledQueue], interval: configuration.pollingInterval)
    }
    
    /// If shouldWait is true, it will wait forever.
    public func start(shouldWait: Bool = false) {
        worker.run()
        
        if config.enableScheduling {
            monitor.run()
        }
        
        guard shouldWait else {
            return
        }
        
        semaphore.wait()
    }
    
}
