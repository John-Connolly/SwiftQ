//
//  Worker.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-07.
//  Copyright © 2017 John Connolly. All rights reserved.
//

import Foundation
import Dispatch

final class Worker {
    
    private let concurrentQueue = DispatchQueue(label: "com.swiftq.concurrent", attributes: .concurrent)
    
    private let queue: ReliableQueue
    
    private let decoder: Decoder
    
    private let semaphore: DispatchSemaphore
    
    private let middlewares: MiddlewareCollection
    
    init(decoder: Decoder,
         config: RedisConfig,
         concurrency: Int,
         queue: String,
         consumerName: String?,
         middleware: [Middleware]) throws {
        self.semaphore = DispatchSemaphore(value: concurrency)
        self.decoder = decoder
        self.middlewares = MiddlewareCollection(middleware)
        self.queue = try ReliableQueue(queue: queue,
                                       config: config,
                                       consumer: consumerName,
                                       concurrency: concurrency)
        try self.queue.prepare()
    }
    
    /// Atomically transfers a task from the work queue into the
    /// processing queue then enqueues it to the worker.
    func run() {
        repeat {
            
            semaphore.wait()
            
            AsyncWorker(queue: concurrentQueue) {
                defer {
                    self.semaphore.signal()
                }
                
                do {
                    
                    let task = try self.queue.bdequeue { data in
                        return try self.decoder.decode(data: data)
                    }
                    
                    task.map(self.execute)
                    
                } catch {
                    Logger.log(error)
                }
                
                }.run()
            
        } while true
        
    }
    
    private func execute(_ task: Task) {
        do {
            
            middlewares.before(task: task)
            
            try task.execute()
            
            middlewares.after(task: task)
            complete(task: task)
            
        } catch {
            middlewares.after(task: task, with: error)
            failure(task, error: error)
        }
    }
    
    /// Called when a task is successfully completed. If the task is
    /// periodic it is re-queued into the zset.
    private func complete(task: Task) {
        do {
            
            if let task = task as? PeriodicTask {
                let box = try PeriodicBox(task)
                try queue.requeue(item: box, success: true)
            } else {
                try queue.complete(item: try EnqueueingBox(task), success: true)
            }
            
        } catch {
            Logger.log(error)
        }
    }
    
    
    /// Called when the tasks fails. Note: If the tasks recovery
    /// stategy is none it will never be ran again.
    private func failure(_ task: Task, error: Error)  {
        do {
            
            switch task.recoveryStrategy {
            case .none:
                try queue.complete(item: EnqueueingBox(task), success: false)
            case .retry:
                if task.retry() {
                    try queue.requeue(item: EnqueueingBox(task), success: false)
                } else {
                    try queue.complete(item: EnqueueingBox(task), success: false)
                }
            case .log:
                try queue.log(task: task, error: error)
            }
            
        } catch {
            Logger.log(error)
        }
    }
}

enum Result<T> {
    case success(T)
    case failure(Error)
}
