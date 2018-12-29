//
//  Consumer.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-04.
//
//

import Foundation
import Dispatch
import NIO

public final class Consumer {
    
//    private let worker: Worker
//
//    private let monitor: QueueMonitor

    private let config: Configuration

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

//        let scheduledQueue = try ScheduledQueue(config: configuration.redisConfig)
//        self.monitor = QueueMonitor(queues: [scheduledQueue], interval: configuration.pollingInterval)
    }
    
    public func run() -> Never {

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let eventloop = group.next()
        let decoder = Decoder(types: config.tasks)
        

        let blockedRedis = AsyncRedis.connect(eventLoop: eventloop)
        let asyncWorker = AsyncRedis
            .connect(eventLoop: eventloop).and(blockedRedis)
            .map(AsyncReliableQueue.init)
            .map {
                AsyncWorker.init(queue: $0, decoder: decoder)
        }

        asyncWorker.whenSuccess {
            $0.run()
        }

        RunLoop.main.run()
        exit(0)
    }
    
}
