//
//  Chainable.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-22.
//
//

import Foundation

public protocol Chainable: Task {
    
    var result: Type? { get set }
    
}

extension Chainable {
    
    var taskType: TaskType {
        return .chainable
    }
    
}

public enum Type {
    
    case string(String)
    case int(Int)
    case array([Type])
    case object([String : Type])
    case bool(Bool)
    case float(Float)
    
}






