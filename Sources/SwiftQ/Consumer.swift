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

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 6)



        for _ in 0..<6 {
            let decoder = Decoder(types: config.tasks)
            let eventloop = group.next()

            _ = eventloop.submit {

                let blockedRedis = AsyncRedis.connect(eventLoop: eventloop)
                let asyncWorker = AsyncRedis
                    .connect(eventLoop: eventloop)
                    .and(blockedRedis)
                    .map(AsyncReliableQueue.init)
                    .map {
                        AsyncWorker.init(queue: $0, decoder: decoder)
                }

                asyncWorker.whenSuccess { worker -> () in
                    AsyncRedis
                        .connect(eventLoop: eventloop)
                        .then {
                            self.run(preparations: self.config.preparations, with: $0)
                        }.whenSuccess {
                            worker.run()
                    }
                }
            }


            
        }


        RunLoop.main.run()
        exit(0)
    }

    func run(preparations: [Preparations], with redis: AsyncRedis) -> EventLoopFuture<()> {
        let results = preparations.map { prepare in
            prepare(redis)
        }
        return flatten(array: results, on: redis.eventLoop).map { _ in
            return ()
        }
    }
}




// TODO: Move this
func flatten<T>(array: [EventLoopFuture<T>], on eventLoop: EventLoop) -> EventLoopFuture<[T]> {
    var expectations: [T] = []
    let promise: EventLoopPromise<[T]> = eventLoop.newPromise()
    array.forEach { future in
        future.whenSuccess { item in
            expectations.append(item)
            if expectations.count == array.count {
                promise.succeed(result: expectations)
            }
        }
        future.whenFailure { error in
            promise.fail(error: error)
        }

    }
    return promise.futureResult
}
