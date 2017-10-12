//
//  RecoveryStrategy.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-17.
//
//

import Foundation
// TODO: - Rename this
public enum RecoveryStrategy {
    
    // Removes task from the queue.
    case none
    // retries the task a specified amount of times
    case retry(Int)
    case log
}
