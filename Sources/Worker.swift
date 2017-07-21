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
    
    init(decoder: Decoder,
         config: RedisConfig,
         concurrency: Int,
         queue: String,
         consumerName: String?) throws {
        self.semaphore = DispatchSemaphore(value: concurrency)
        self.decoder = decoder
        self.reliableQueue = try ReliableQueue(queue: queue, config: config, consumer: consumerName)
        try self.reliableQueue.prepare()
    }
    
    /// Atomically transfers a task from the work queue into the
    /// processing queue then enqueues it to the worker.
    func run() {
        brpoplpushQueue.async {
            while true {
                do {
                    guard let data = try self.reliableQueue.brpoplpush() else { continue }
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
                try chain.execute()
            } catch {
                self.complete(chain: chain, success: false)
                return
            }
            self.complete(chain: chain, success: true)
        }
    }
    
    
    private func execute(_ task: Task) {
        
        let work = workItem(for: task) { result in
            switch result {
            case .success(let task):
                self.complete(task: task)
            case .failure(let task,let error):
                self.failure(task, error: error)
            }
            
        }
        concurrent(work)
    }
    
    
    private func workItem(for task: Task, _ complete: @escaping (_ result: Result<Task>) ->  ()) -> DispatchWorkItem {
        let item = DispatchWorkItem {
            
            defer { self.semaphore.signal() }
            
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
    
    
    private func complete(task: Task) {
        do {
            switch task.taskType {
            case .periodic:
                guard let periodicTask = task as? PeriodicTask else {
                    throw SwiftQError.periodicTaskFailure(task)
                }
                let scheduledTask = try ScheduledTask(periodicTask, when: periodicTask.frequency.nextTime)
                try reliableQueue.finished(periodicTask: scheduledTask, success: true)
            default:
                try reliableQueue.finished(task: try task.serialized(), success: true)
            }
        } catch {
            Logger.log(error)
        }
    }
    
    private func complete(chain: Chain, success: Bool) {
        do {
            let data = try chain.serialized()
            try reliableQueue.finished(task: data, success: success)
        } catch {
            Logger.log(error)
        }
    }
    
    
    private func failure(_ task: Task, error: Error)  {
        do {
            switch task.recoveryStrategy {
            case .none:
                try reliableQueue.finished(task: try task.serialized(), success: false)
            case .retry(_):
                break
            case .log:
                let log = try task.createLog(with: error)
                try reliableQueue.log(task: try task.serialized(), log: log)
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
