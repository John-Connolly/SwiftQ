//
//  BlockedClientPool.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-03.
//

import Foundation
import Async
import Redis

final class BlockedClientPool {
    
    let eventLoop: EventLoop
    
    var waitQueue = [Promise<Client>]()// {
//        didSet {
//            print(waitQueue.count)
//            print(pool.count)
//        }
   // }
    
    /// A list of all currently active connections
    var pool = [Client]() 
    
    public var maxClients: Int
    
    var remainingClients: Int {
        print(pool.count)
        return maxClients - pool.count
    }
    
    class Client {
        let connection: RedisClient
        var blocked = false
        
        init(connection: RedisClient) {
            self.connection = connection
        }
    }
    
    
    init(on eventLoop: EventLoop, clients: Int) {
        self.eventLoop = eventLoop
        self.maxClients = clients
    }
    
    func release(_ pair: Client) {
        pair.blocked = false
        
        if waitQueue.count > 0 {
            waitQueue.removeFirst().complete(pair)
        }
    }
    
    
    typealias Complete = (()->())
    
    public func retain<T>(_ handler: @escaping ((RedisClient) -> Future<T>)) -> Future<T> {
        let promise = Promise<Client>()
        
        let future = promise.future.flatMap { pair -> Future<T> in
            pair.blocked = true
            
            // Runs the handler with the connection
            let future = handler(pair.connection)
            
            future.do { _ in
                self.release(pair)
                }.catch { _ in
                    self.release(pair)
            }
            
            return future
        }
        
        // Checks for an existing connection
        for pair in pool where !pair.blocked {
            promise.complete(pair)
            
            return future
        }
        
        if self.pool.count == maxClients {
            let connectionPromise = Promise<Client>()
            
            waitQueue.append(connectionPromise)
            
            connectionPromise.future.do(promise.complete).catch(promise.fail)
            
            return future
        }
        
        // FIXME: Handle this error
        try! RedisClient.connect(on: eventLoop).do { client in
            let pair = Client(connection: client)
//            pair.blocked = true
            
            self.pool.append(pair)
            
            promise.complete(pair)
            }.catch(promise.fail)
        
        
        
        return future
    }
    
    
    
}
