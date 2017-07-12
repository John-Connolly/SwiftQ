//
//  RecoveryStrategy.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-17.
//
//

import Foundation

public enum RecoveryStrategy {
    
    // Removes task from the queue.
    case none
    // retries the task a specified amount of times
    case retry(times: Int)
    case log
}
