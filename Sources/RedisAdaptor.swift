//
//  RedisAdaptor.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation
import Redis

final class RedisAdaptor: Adaptor {
    
    let pool: ConnectionPool<Redis.TCPClient>
    
    init(config: RedisConfig, connections: Int) throws {
        self.pool = try ConnectionPool(max: connections) {
            return try Redis.TCPClient(hostname: config.hostname, port: config.port, password: config.password)
        }
        
        guard let database = config.redisDB else {
            return
        }
        
        let command = Command.select(db: database)
        try self.pool.connections.forEach { connection in
            try connection.command(Redis.Command(command.rawValue), command.params)
        }
    }
    
    @discardableResult
    func execute(_ command: Command) throws -> RedisResponseRepresentable {
        let client = pool.borrow()
        defer {
            pool.takeBack(connection: client)
        }
        return VaporRedisResponse(response: try client.command(Redis.Command(command.rawValue), command.params))
    }

    @discardableResult
    func pipeline(_ commands: () -> ([Command])) throws -> [RedisResponseRepresentable] {
        let client = pool.borrow()
        defer {
            pool.takeBack(connection: client)
        }
        let commands = commands()
        let pipeline = client.makePipeline()
        try commands.forEach { command in
            try pipeline.enqueue(Redis.Command(command.rawValue), command.params)
        }
        return try pipeline.execute().map(VaporRedisResponse.init)
    }
    
}


protocol Adaptor: class {
    
    @discardableResult
    func execute(_ command: Command) throws -> RedisResponseRepresentable
    
    @discardableResult
    func pipeline(_ commands: () -> ([Command])) throws -> [RedisResponseRepresentable]
    
    init(config: RedisConfig, connections: Int) throws
    
}

enum Command {
    
    // transactions
    case multi
    case exec
    
    // connection
    case select(db: Int)
    
    // list
    case lrem(key: String, count: Int, value: String)
    case lpush(key: String, values: [BytesRepresentable])
    case lrange(key: String, start: Int, stop: Int)
    case brpoplpush(q1: String, q2: String, timeout: Int)
    
    // keys
    case get(key: String)
    case del(key: String)
    case set(key: String, value: BytesRepresentable)
    case mset(EnqueueingBoxes)
    case incr(key: String)
    
    // sorted set
    case zadd(queue: String, score: String, value: String)
    case zrangebyscore(key: String, min: String, max: String)
    case zrem(key: String, values: [BytesRepresentable])
    
    // set
    case sadd(key: String, value: String)
    
    
    var rawValue: String {
        switch self {
        case .multi: return "MULTI"
        case .exec: return "EXEC"
        case .select: return "SELECT"
        case .lrem: return "LREM"
        case .lpush: return "LPUSH"
        case .lrange: return "LRANGE"
        case .brpoplpush: return "BRPOPLPUSH"
        case .get: return "GET"
        case .set: return "SET"
        case .del: return "DEL"
        case .mset: return "MSET"
        case .incr: return "INCR"
        case .zadd: return "ZADD"
        case .sadd: return "SADD"
        case .zrangebyscore: return "ZRANGEBYSCORE"
        case .zrem: return "ZREM"
        }
    }
    
    var params: [BytesRepresentable] {
        switch self {
        case .multi:
            return []
        case .exec:
            return []
        case .select(let db):
            return [db.description]
        case .lrem(let key, let count, let value):
            return [key, count.description, value]
        case .lpush(let key, let values):
            return values.prepend(key)
        case .lrange(let key,let start, let stop):
            return [key, start.description, stop.description]
        case .brpoplpush(let q1, let q2, let timeout):
            return [q1, q2, timeout.description]
        case .get(let key):
            return [key]
        case .set(let key, let value):
            return [key, value]
        case .del(let key):
            return [key]
        case .mset(let box):
            return box.bytesRepresentable
        case .incr(let key):
            return [key]
        case .zadd(let queue, let score, let value):
            return [queue, score, value]
        case .zrangebyscore(let key,let min, let max):
            return [key,min,max]
        case .zrem(let key, let values):
            return values.prepend(key)
        case .sadd(let key, let value):
            return [key, value]
        }
    }
    
}

struct EnqueueingBoxes {
    
    private let boxes: [EnqueueingBox]
    
    init(_ boxes: [EnqueueingBox]) {
        self.boxes = boxes
    }
    
    var bytesRepresentable: [BytesRepresentable] {
        return boxes.reduce(into: []) { (args: inout [BytesRepresentable], box) in
            let keyAndValue:[BytesRepresentable] = [box.uuid, box.value]
            args.append(contentsOf: keyAndValue)
        }
    }
    
}

