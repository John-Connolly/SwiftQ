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
    
    private let client: Redis.TCPClient
    
    let pool: ConnectionPool<Redis.TCPClient>
    
    init(config: RedisConfig) throws {
        self.pool = try ConnectionPool(max: config.connections) {
            return try Redis.TCPClient(hostname: config.hostname, port: config.port, password: config.password)
        }
        self.client = try Redis.TCPClient(hostname: config.hostname, port: config.port, password: config.password)
        if let database = config.redisDB {
            try execute(Command(command: "SELECT", args: [.string(database.description)]))
        }
    }
    
    @discardableResult
    func execute(_ command: Command) throws -> RedisResponseRepresentable {
        let client = pool.borrow()
        defer { pool.takeBack(connection: client) }
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
    
    init(config: RedisConfig) throws
    
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
