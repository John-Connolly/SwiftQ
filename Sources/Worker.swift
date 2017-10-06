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
    
    let middleware: [Middleware]
    
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
        return DispatchWorkItem { [unowned self] in
            
            defer {
                self.semaphore.signal()
            }
            
            do {
                
                guard let data = try self.reliableQueue.dequeue() else {
                    return
                }
                
                let task = try self.decoder.decode(data: data)
                self.execute(task)

            } catch {
                Logger.log("Failed to decode task")
            }
        }
    }
    
    
    private func execute(_ task: Task) {
        do {
            before(task: task)
            try task.execute()
            after(task: task)
            complete(task: task)
        } catch {
            after(task: task, with: error)
            failure(task, error: error)
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

extension Worker: Middlewareable { }

protocol Middlewareable: class {
    
    var middleware: [Middleware] { get }
    
}

extension Middlewareable {
    
    func before(task: Task) {
        self.middleware.forEach { middleware in
            middleware.before(task: task)
        }
    }
    
    func after(task: Task) {
        self.middleware.forEach { middleware in
            middleware.after(task: task)
        }
    }
    
    func after(task: Task, with error: Error) {
        self.middleware.forEach { middleware in
            middleware.after(task: task, with: error)
        }
    }
}
