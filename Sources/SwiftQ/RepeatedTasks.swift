//
//  RepeatedTasks.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-02.
//

import Foundation
import NIO

public typealias RepeatedTasks = (Redis) -> EventLoopFuture<()>

public func heartBeat(redis: Redis) -> EventLoopFuture<()> {
    return redis.send(.get(key: Host().name)).thenThrowing { value -> ConsumerInfo? in
        return try (value.data).map(decode)
        }.thenThrowing { info -> Data in
            var info = try info.or(throw: "Invalid data stored at key \(Host().name)")
            info.incrHeartbeat()
            return try encode(item: info)
        }.thenThrowing { data in
            return redis.send(.set(key: Host().name, value: data))
        }.map { _ in
            return ()
    }
}

final class RepeatedTaskRunner {

    let eventloop: EventLoop
    let redis: Redis
    let tasks: [(Redis) -> EventLoopFuture<()>]

    var canceled = false

    init(on eventloop: EventLoop,
         with redis: Redis,
         tasks: [(Redis) -> EventLoopFuture<()>]) {
        self.eventloop = eventloop
        self.redis = redis
        self.tasks = tasks
    }

    func run() {
        let _ = eventloop.scheduleTask(in: TimeAmount.seconds(3)) {
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

    static func connect(on eventloop: EventLoop, with tasks: [RepeatedTasks]) -> EventLoopFuture<RepeatedTaskRunner> {
        return Redis
            .connect(eventLoop: eventloop)
            .map { redis in
               return RepeatedTaskRunner(on: eventloop, with: redis, tasks: tasks)
            }
    }

}
