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
    case valueNotFound
    case noStatsAvailable
    case taskNotFound
    case tasksNotRegistered
    case invalidConcurrency(Int)
    case invalidQueueName(String)
    case periodicTaskFailure(Task)
    case chainFailedToInitialize([Task])
    
}
