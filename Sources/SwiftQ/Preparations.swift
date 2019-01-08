//
//  Preparations.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-02.
//

import Foundation
import NIO

public typealias Preparations = (AsyncRedis) -> EventLoopFuture<()>

public func onBoot(redis: AsyncRedis) -> EventLoopFuture<()> {
    let hostname = Host().name
    return redis.send(.sadd(key: RedisKey.processes, value: hostname)).map { _ in
        return ()
    }
}

public func consumerInfo(redis: AsyncRedis) -> EventLoopFuture<()> {
    let consumerInfo = ConsumerInfo.initial
    let data = encode(item: consumerInfo)
    return redis.send(.set(key: Host().name, value: data)).map { value -> () in
        return ()
    }
}
