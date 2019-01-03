//
//  RepeatedTasks.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-02.
//

import Foundation
import NIO

public typealias RepeatedTasks = (AsyncRedis) -> EventLoopFuture<()>

public func heartBeat(redis: AsyncRedis) -> EventLoopFuture<()> {
    return redis.send(.get(key: Host().name)).map { value -> ConsumerInfo? in
        return (value.data).map(decode)
        }.map { info -> Data in
            var info = info! // fix me!!
            info.incrHeartbeat()
            return encode(item: info)
        }.thenThrowing { data in
            return redis.send(.set(key: Host().name, value: data))
        }.map { _ in
            return ()
    }
}

final class RepeatedTaskRunner {

    let eventloop: EventLoop
    let redis: AsyncRedis
    let tasks: [(AsyncRedis) -> EventLoopFuture<()>]

    var canceled = false

    init(on eventloop: EventLoop,
         with redis: AsyncRedis,
         tasks: [(AsyncRedis) -> EventLoopFuture<()>]) {
        self.eventloop = eventloop
        self.redis = redis
        self.tasks = tasks
    }

    func run() {
        let _ = eventloop.scheduleTask(in: TimeAmount.seconds(10)) {
            if !self.canceled {
                self.runReapeted().whenComplete {
                    self.run()
                }
            }
        }
    }

    private func runReapeted() -> EventLoopFuture<[()]> {
        return flatten(array: tasks.map { $0(redis) }, on: eventloop)
    }

    public static func connect(on eventloop: EventLoop, with tasks: [RepeatedTasks]) -> EventLoopFuture<RepeatedTaskRunner> {
        return AsyncRedis
            .connect(eventLoop: eventloop)
            .map { redis in
               return RepeatedTaskRunner(on: eventloop, with: redis, tasks: tasks)
            }
    }
    
}
