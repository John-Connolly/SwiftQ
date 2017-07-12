//
//  Injectable.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-07.
//  Copyright © 2017 John Connolly. All rights reserved.
//

import Foundation


public protocol Injectable: Task {
    
    var injection: Type? { get set }
    
}

extension Injectable {
    
    var taskType: TaskType {
        return .injectable
    }
}


public protocol Linkable: Injectable, Chainable { }

extension Linkable {
    
    var taskType: TaskType {
        return .linkable
    }
}
