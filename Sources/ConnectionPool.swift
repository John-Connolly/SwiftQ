//
//  ConnectionPool.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-08-09.
//
//

import Foundation
import Dispatch

final class ConnectionPool<T> {
    
    var connections = [T]()
    
    private let connectionFactory: () throws -> T
    
    private let max: Int
    
    private let semaphore: DispatchSemaphore
    /// Semaphore seems to perform much better that a serial queue
    /// Probably related to the extra heap allocation of the sync { } closure.
    private let lock = DispatchSemaphore(value: 1)
    
    
    init(max: Int, factory: @escaping () throws -> T) throws {
        self.max = max
        self.connectionFactory = factory
        self.semaphore = DispatchSemaphore(value: max)
        
        try (0..<max).forEach { _ in
            connections.append(try factory())
        }
    }
    
    /// Borrows a connection from the pool.  Any borrowed connections
    /// have to be returned.  If all connections are borrowed the semaphore
    /// will block until one is returned.
    func borrow() -> T {
        defer {
            lock.signal()
        }
        semaphore.wait()
        lock.wait()
        return connections.removeFirst()
        
    }
    
    /// Returns the connection to the pool.
    func takeBack(connection: T) {
        defer {
            lock.signal()
        }
        lock.wait()
        connections.append(connection)
        semaphore.signal()
    }
    
}
