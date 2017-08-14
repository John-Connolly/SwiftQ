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
        
        let command = Command(command: "SELECT", args: [.string(database.description)])
        try self.pool.connections.forEach { connection in
            try connection.command(Redis.Command(command.command), command.bytes)
        }
    }
    
    @discardableResult
    func execute(_ command: Command) throws -> RedisResponseRepresentable {
        let client = pool.borrow()
        defer {
            pool.takeBack(connection: client)
        }
        return VaporRedisResponse(response: try client.command(Redis.Command(command.command), command.bytes))
    }
    
    
    @discardableResult
    func pipeline(_ commands: () -> ([Command])) throws -> [RedisResponseRepresentable] {
        let client = pool.borrow()
        defer {
            pool.takeBack(connection: client)
        }
        let arguments = commands()
        let pipeline = client.makePipeline()
        try arguments.forEach { argument in
            try pipeline.enqueue(Redis.Command(argument.command), argument.bytes)
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

// Need to decouple BytesRepresentable
enum ArgumentsType {
    
    case data(Foundation.Data)
    case string(String)
    
    var bytesRepresentable: BytesRepresentable {
        switch self {
        case .data(let data):
            return data
        case .string(let string):
            return string
        }
    }
    
}


// Need to decouple BytesRepresentable
struct Command {
    
    let command: String
    let args: [ArgumentsType]
    
    var bytes: [BytesRepresentable] {
        return args.map { $0.bytesRepresentable }
    }
    
}

extension Command {
    
    init(command: String) {
        self.command = command
        self.args = []
    }
}
