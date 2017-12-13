//
//  EventSource.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-03.
//

import Foundation
import Redis
import Async

final class EventSource {
    
    let queue: DispatchQueue
    
    var eventHandler: ((RedisData) -> ())?
    
    let poolFuture: Future<BlockedClientPool>
    
    init(on queue: DispatchQueue, clients: Int) throws {
        self.queue = queue
        let promise = Promise<BlockedClientPool>()
        queue.async {
            let pool = BlockedClientPool(on: queue, clients: clients)
            promise.complete(pool)
        }
        self.poolFuture = promise.future
    }
    
    func resume() -> Future<RedisData> {
        let promise = Promise<RedisData>()
        
        queue.async {
        
            self.poolFuture.flatMap { pool in

                return pool.retain { client in
                    client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"])
                }
                }.do { data in
                    promise.complete(data)
                }.catch(promise.fail)
            
        }
        
        return promise.future
    
    }
    
    //    private func getTask() -> Future<RedisData> {
    //        let promise = Promise<RedisData>()
    //            self.pool.retain { client in
    //                client.run(command: "BRPOPLPUSH", arguments: ["myList","newList","0"])
    //                }.do { data in
    //                    promise.complete(data)
    //                }.catch(promise.fail)
    //
    //        return promise.future
    //    }
    
}

