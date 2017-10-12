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
        return RedisResponse(response: try client.command(Redis.Command(command.rawValue), command.params))
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
        return try pipeline.execute().map(RedisResponse.init)
    }
    
}


protocol Adaptor: class {
    
    @discardableResult
    func execute(_ command: Command) throws -> RedisResponseRepresentable
    
    @discardableResult
    func pipeline(_ commands: () -> ([Command])) throws -> [RedisResponseRepresentable]
    
    init(config: RedisConfig, connections: Int) throws
    
}
