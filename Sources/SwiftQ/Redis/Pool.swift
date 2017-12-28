//
//  Pool.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-27.
//

import Foundation
import Async

/// A pool used for Redis blocking commands. This is a non thread safe pool
/// implementation
final class Pool<T> {
    
    /// The maximum number of connections this pool should hold.
    public let max: UInt
    
    /// The current number of active connections.
    private var active: UInt
    
    /// Available connections.
    private var available: [T]
    
    /// Notified when more connections are available.
    private var waiters: [(T) -> ()]
    
    private let connectionFactory: () -> Future<T>
    
    
    init(max: UInt, factory: @escaping () -> Future<T>) throws {
        self.max = max
        self.active = .min
        self.available = []
        self.waiters = []
        self.connectionFactory = factory
    }
    
    func requestConnection() -> Future<T> {
        let promise = Promise<T>()
        if let ready = self.available.popLast() {
            
            promise.complete(ready)
            
        } else if self.active < self.max {
            connectionFactory().do { connection in
                
                self.active += 1
                promise.complete(connection)
                
                }.catch(promise.fail)
            
        } else {
            self.waiters.append(promise.complete)
        }
        
        return promise.future
    }
    
    func returnConnection(_ connection: T) {
        if let waiter = self.waiters.popLast() {
            waiter(connection)
        } else {
            self.available.append(connection)
        }
    }
}
