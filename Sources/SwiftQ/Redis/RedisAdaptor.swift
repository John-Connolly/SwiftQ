//
//  RedisAdaptor.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation
import Async
import Redis

// TODO: Authorization
// TODO: Pipelinening
// TODO: Figure out if multiple clients are needed if they are not running
// blocking commands
final class RedisAdaptor {
    
    private let client: Future<RedisClient>
    
    init(with config: RedisConfiguration, connections: Int, on eventLoop: EventLoop) throws {
        let client = try RedisClient.connect(hostname: config.hostname, port: config.port, on: eventLoop)
        let command = Command.select(db: config.redisDB ?? 0)
        
        self.client = client.run(command: command.command, arguments: command.arguments).flatMap(to: RedisClient.self) { data -> Future<RedisClient> in
            return Future(client)
        }
    }
    
    @discardableResult
    func execute(command: Command) -> Future<RedisResponse> {
        return client
            .flatMap(to: RedisData.self) { client in
                client.run(command: command.command, arguments: command.arguments)
            }
            .map(to: RedisResponse.self) { data in
                RedisResponse(response: data)
        }
    }
    
    
    func pipeline() {
        
    }
    
}

