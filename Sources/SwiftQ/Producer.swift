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


    private let reliableQueue: RedisQueue

    public init(reliableQueue: RedisQueue) {
        self.reliableQueue = reliableQueue
    }

    public static func connect(on eventloop: EventLoop) -> EventLoopFuture<Producer> {
        let blockedRedis = Redis.connect(eventLoop: eventloop)
        return Redis
            .connect(eventLoop: eventloop)
            .and(blockedRedis)
            .map(RedisQueue.init)
            .map(Producer.init)
    }

    /// Pushes a task onto the the tasks specific queue.  Unless specified
    /// this will be the default work queue.
    public func enqueue<T: Task>(task: T) -> EventLoopFuture<Int> {
        let taskInfo = TaskInfo(task)
        return reliableQueue.enqueue(task: taskInfo)
    }

    /// Pushes multiple tasks onto the default work queue only.
    public func enqueue<T: Task>(tasks: [T]) -> EventLoopFuture<Int> {
        return reliableQueue.enqueue(contentsOf: tasks.map(TaskInfo.init))
    }


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
