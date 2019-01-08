//
//  SwiftQError.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation

public enum SwiftQError: Swift.Error {
    
    case initializationFailure([String : Any])
    case taskNotFound
    case unimplemented
    case tasksNotRegistered
    case invalidConcurrency(Int)
    case invalidQueueName(String)
    case invalidType(String) // TODO: Rename this!
    
}

extension SwiftQError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .initializationFailure: return "Key not found or value is the wrong type"
        case .taskNotFound: return "Make sure all tasks are registered in the configuration"
        case .tasksNotRegistered: return "No tasks have been registered"
        case .invalidConcurrency: return "Concurrency cannot be zero"
        case .invalidQueueName: return "Queue name cannot be empty string"
        case .unimplemented: return nil
        case .invalidType(let reason): return reason
        }
    }
    
}
