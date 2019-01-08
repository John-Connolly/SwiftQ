//
//  Task.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-07.
//  Copyright © 2017 John Connolly. All rights reserved.
//

import Foundation
import NIO

public protocol Task: Codable {

    func execute(loop: EventLoop) -> EventLoopFuture<()>
    
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

    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }

    static func create(from data: Data) throws -> Task {
        return try JSONDecoder().decode(TaskInfo<Self>.self, from: data).task
    }


    func log(with error: Error, consumer: String) {
//        let log = Log(message: error.localizedDescription,
//                      consumer: consumer,
//                      date: Date().unixTime)
//        storage.set(log: log)
    }
    

    func shouldRetry(_ retries: Int) -> Bool {
        fatalError()
    }
    
    func retry() {
        fatalError()
    }
    
}

protocol Loggable: class {
    
    func log(with error: Error, consumer: String) throws -> Data
    
}

