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
    
    private let queue = DispatchQueue(label: "com.swiftq.worker")
    
    private let serialQueue = DispatchQueue(label: "com.swiftq.serial")
    
    private let concurrentQueue = DispatchQueue(label: "com.swiftq.concurrent", attributes: .concurrent)
    
    private let reliableQueue: ReliableQueue
    
    private let decoder: Decoder
    
    private let semaphore: DispatchSemaphore
    
    private let middleware: [Middleware]
    
    init(decoder: Decoder,
         config: RedisConfig,
         concurrency: Int,
         queue: String,
         consumerName: String?,
         middleware: [Middleware]) throws {
        self.semaphore = DispatchSemaphore(value: concurrency)
        self.decoder = decoder
        self.middleware = middleware
        self.reliableQueue = try ReliableQueue(queue: queue, config: config, consumer: consumerName, concurrency: concurrency)
        try self.reliableQueue.prepare()
    }
    
    /// Atomically transfers a task from the work queue into the
    /// processing queue then enqueues it to the worker.
    func run() {
        queue.async { [unowned self] in
            repeat {
                self.semaphore.wait()
                let workItem = self.workItem()
                self.concurrentQueue.async(execute: workItem)
            } while true
        }
        
    }
    
    private func workItem() -> DispatchWorkItem {
        let item = DispatchWorkItem { [unowned self] in
            
            defer {
                self.semaphore.signal()
            }
            
            do {
                guard let data = try self.reliableQueue.dequeue() else { return }
                let result = try self.decoder.decode(data: data)
                switch result {
                case .chain(let chain):
                    self.execute(chain)
                case .task(let task):
                    self.execute(task)
                }
            } catch {
                Logger.log("Failed to decode task")
            }
        }
        return item
    }
    
    /// Executes a chain. If one of the items in the chain fails
    /// the remaining tasks are canceled
    private func execute(_ chain: Chain) {
        serialQueue.sync {
            do {
                try chain.execute ({ before in
                    self.middleware.forEach { $0.before(task: before) }
                }) { after in
                    self.middleware.forEach { $0.after(task: after) }
                }
            } catch {
                self.complete(chain: chain, success: false)
                return
            }
            self.complete(chain: chain, success: true)
        }
    }
    
    private func execute(_ task: Task) {
        do {
            self.middleware.forEach { $0.before(task: task) }
            try task.execute()
            self.middleware.forEach { $0.after(task: task) }
            self.complete(task: task)
        } catch {
            self.middleware.forEach { $0.after(task: task, with: error) }
            self.failure(task, error: error)
        }
    }
    
    /// Called when a task is successfully completed. If the task is
    /// periodic it is re-queued into the zset.
    private func complete(task: Task) {
        do {
            switch task {
            case let task as PeriodicTask:
                let box = try PeriodicBox(task)
                try reliableQueue.requeue(box: box, success: true)
            default:
                try reliableQueue.complete(item: try EnqueueingBox(task), success: true)
            }
        } catch {
            Logger.log(error)
        }
    }
    
    private func complete(chain: Chain, success: Bool) {
        do {
            try reliableQueue.complete(item: EnqueueingBox(chain), success: success)
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
                try reliableQueue.complete(item: EnqueueingBox(task), success: false)
            case .retry: break
            case .log:
                try reliableQueue.log(task: task, error: error)
            }
        } catch {
            Logger.log(error)
        }
    }
}
