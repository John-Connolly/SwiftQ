//
//  Producer.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation
import NIO

public final class Producer {

//    private let scheduledQueue: ScheduledQueue

    private let reliableQueue: AsyncReliableQueue

    public init(reliableQueue: AsyncReliableQueue) {
        self.reliableQueue = reliableQueue
    }

    public static func connect(on eventloop: EventLoop) -> EventLoopFuture<Producer> {
        let blockedRedis = AsyncRedis.connect(eventLoop: eventloop)
        return AsyncRedis
            .connect(eventLoop: eventloop)
            .and(blockedRedis)
            .map(AsyncReliableQueue.init)
            .map(Producer.init)
    }

   /// Pushes a task onto the the tasks specific queue.  Unless specified
   /// this will be the default work queue.
    public func enqueue<T: Task>(task: T) -> EventLoopFuture<Int> {
        let taskInfo = TaskInfo(task)
        return reliableQueue.enqueue(task: taskInfo)
    }

//    /// Pushes multiple tasks onto the default work queue only.
//    public func enqueue(tasks: [Task]) throws {
//        let boxes = try tasks.map(EnqueueingBox.init)
//        try reliableQueue.enqueue(contentsOf: boxes)
//    }
//    
//    /// Pushes a task on the scheduled queue
//    public func enqueue(task: Task, time: Time) throws {
////        task.storage.set(type: .scheduled)
//        let box = try ScheduledBox(task, when: time)
//        try scheduledQueue.enqueue(box)
//    }
//    
//    /// Pushes a task on the scheduled queue, after the task is completed it is pushed back
//    /// onto the scheduled queue.
//    public func enqueue(periodicTask: PeriodicTask) throws {
////        periodicTask.storage.set(type: .periodic)
//        let box = try PeriodicBox(periodicTask)
//        try scheduledQueue.enqueue(box)
//    }
    
}
