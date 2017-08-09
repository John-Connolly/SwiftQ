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
    
    private let brpoplpushQueue = DispatchQueue(label: "com.swiftq.brpoplpush")
    
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
        self.reliableQueue = try ReliableQueue(queue: queue, config: config, consumer: consumerName)
        try self.reliableQueue.prepare()
    }
    
    /// Atomically transfers a task from the work queue into the
    /// processing queue then enqueues it to the worker.
    func run() {
        brpoplpushQueue.async { [unowned self] in
            while true {
                do {
                    guard let data = try self.reliableQueue.dequeue() else { return }
                    try self.decode(data)
                    
                } catch {
                    Logger.log(("Decoding Failure", error))
                }
            }
        }
        
    }
    
    private func decode(_ data: Data) throws {
        let result = try decoder.decode(data: data)
        switch result {
        case .chain(let chain):
            execute(chain)
        case .task(let task):
            execute(task)
        }
    }
    
    
    /// Executes a chain. If one of the items in the chain fails
    /// the remaining tasks are canceled
    private func execute(_ chain: Chain) {
        serialQueue.async {
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
        
        let work = workItem(for: task) { [unowned self] result in
            switch result {
            case .success(let task):
                self.middleware.forEach { $0.after(task: task) }
                self.complete(task: task)
            case .failure(let task, let error):
                self.middleware.forEach { $0.after(task: task, with: error) }
                self.failure(task, error: error)
            }
            
        }
        concurrent(work)
    }
    
    
    private func workItem(for task: Task, _ complete: @escaping (_ result: Result<Task>) ->  ()) -> DispatchWorkItem {
        let item = DispatchWorkItem { [unowned self] in
            
            defer { self.semaphore.signal() }
            
            self.middleware.forEach { $0.before(task: task) }
            
            do {
                try task.execute()
                complete(.success(task))
            } catch {
                complete(.failure(task, with: error))
                Logger.log(error)
            }
        }
        return item
    }
    
    
    private func serial(_ workItem: DispatchWorkItem) {
        serialQueue.async(execute: workItem)
    }
    
    
    private func concurrent(_ workItem: DispatchWorkItem) {
        semaphore.wait()
        concurrentQueue.async(execute: workItem)
    }
    
    /// Called when a task is successfully completed. If the task is
    /// periodic it is re-queued into the zset.
    private func complete(task: Task) {
        do {
            switch task.taskType {
            case .periodic:
                
                guard let periodicTask = task as? PeriodicTask else {
                    throw SwiftQError.periodicTaskFailure(task)
                }
                
                let box = try PeriodicBox(periodicTask)
                try reliableQueue.finished(box: box, success: true)
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
            case .retry(_):
                break
            case .log:
                try reliableQueue.log(task: task, error: error)
            }
        } catch {
            Logger.log(error)
        }
    }
}

enum Result<T> {
    case success(T)
    case failure(_: T, with: Error)
}
