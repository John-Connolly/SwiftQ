//
//  Task.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-07.
//  Copyright © 2017 John Connolly. All rights reserved.
//

import Foundation

public protocol Task: Codable {
    
    var storage: Storage { get }
    
    func execute() throws 
    
    var recoveryStrategy: RecoveryStrategy { get }
    
    var queue: String { get }
    
}

extension Task {
    
    
    public var recoveryStrategy: RecoveryStrategy {
        return .none
    }
    
    public var queue: String {
        return "default"
    }
    
    var uuid: String {
        return storage.uuid
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
    
    func log(with error: Error, consumer: String) throws -> Data {
        let log = Log(message: error.localizedDescription, consumer: consumer, date: Date().unixTime)
        storage.set(log: log)
        return try data()
    }
    
    func data() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    func retry() -> Bool {
        guard case let RecoveryStrategy.retry(retries) = recoveryStrategy, retries > storage.retryCount else {
            return false
        }
        storage.incRetry()
        return true
    }
    
}

protocol Loggable: class {
    
    func log(with error: Error, consumer: String) throws -> Data
    
}

